"""Export OpenAPI schema and Postman collection from FastAPI application."""

import json
from pathlib import Path
import sys

backend_dir = Path(__file__).resolve().parent.parent
repo_root = backend_dir.parent
sys.path.insert(0, str(backend_dir))
sys.path.insert(0, str(repo_root))

from app.main import app


def generate_postman_collection(openapi_schema: dict) -> dict:
    """Generate Postman v2.1.0 collection from OpenAPI 3.x schema."""
    collection = {
        "info": {
            "_postman_id": "kabadiwala-connect-api",
            "name": openapi_schema.get("info", {}).get("title", "Kabadiwala Connect API"),
            "description": openapi_schema.get("info", {}).get("description", ""),
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
            "version": openapi_schema.get("info", {}).get("version", "1.0.0"),
        },
        "item": [],
        "variable": [
            {
                "key": "baseUrl",
                "value": "http://localhost:8000",
                "type": "string",
            },
            {
                "key": "collectorToken",
                "value": "",
                "type": "string",
            },
            {
                "key": "adminToken",
                "value": "",
                "type": "string",
            },
        ],
    }

    folders: dict[str, list] = {}

    for path, methods in openapi_schema.get("paths", {}).items():
        for method, details in methods.items():
            if method.lower() not in ["get", "post", "put", "patch", "delete"]:
                continue

            tag = details.get("tags", ["General"])[0]
            summary = details.get("summary", f"{method.upper()} {path}")
            description = details.get("description", "")

            # Path variables and segments
            path_segments = [s for s in path.strip("/").split("/") if s]
            url_obj = {
                "raw": "{{baseUrl}}" + path,
                "host": ["{{baseUrl}}"],
                "path": path_segments,
            }

            headers = [
                {
                    "key": "Content-Type",
                    "value": "application/json",
                    "type": "text",
                }
            ]

            # Auth header if protected
            if details.get("security") or ("auth" not in path or "me" in path):
                headers.append(
                    {
                        "key": "Authorization",
                        "value": "Bearer {{collectorToken}}",
                        "type": "text",
                    }
                )

            item = {
                "name": summary,
                "request": {
                    "method": method.upper(),
                    "header": headers,
                    "url": url_obj,
                    "description": description,
                },
                "response": [],
            }

            # Sample request body if present
            if "requestBody" in details:
                content = details["requestBody"].get("content", {})
                if "application/json" in content:
                    item["request"]["body"] = {
                        "mode": "raw",
                        "raw": "{}",
                        "options": {"raw": {"language": "json"}},
                    }

            if tag not in folders:
                folders[tag] = []
            folders[tag].append(item)

    for tag, items in folders.items():
        collection["item"].append(
            {
                "name": tag,
                "item": items,
            }
        )

    return collection


def main():
    docs_dir = Path(__file__).resolve().parent.parent.parent / "docs"
    docs_dir.mkdir(parents=True, exist_ok=True)

    openapi_schema = app.openapi()

    # 1. Export OpenAPI JSON
    openapi_path = docs_dir / "openapi.json"
    with open(openapi_path, "w", encoding="utf-8") as f:
        json.dump(openapi_schema, f, indent=2, ensure_ascii=False)
    print(f"Exported OpenAPI spec to: {openapi_path}")

    # 2. Export Postman Collection v2.1.0
    postman_coll = generate_postman_collection(openapi_schema)
    postman_path = docs_dir / "postman_collection.json"
    with open(postman_path, "w", encoding="utf-8") as f:
        json.dump(postman_coll, f, indent=2, ensure_ascii=False)
    print(f"Exported Postman collection to: {postman_path}")


if __name__ == "__main__":
    main()
