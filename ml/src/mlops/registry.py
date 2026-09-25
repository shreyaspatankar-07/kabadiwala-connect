"""Model Registry & Version Manifest Management."""

import datetime
import hashlib
import json
from pathlib import Path
from typing import Any


def compute_file_sha256(file_path: Path | str) -> str:
    """Compute SHA256 hex digest of a binary model file."""
    path = Path(file_path)
    if not path.exists():
        return ""
    sha = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            sha.update(chunk)
    return sha.hexdigest()


class ModelRegistry:
    """Manages versioned models and the manifest models.json file."""

    def __init__(self, registry_dir: Path | str | None = None):
        if registry_dir:
            self.registry_dir = Path(registry_dir)
        else:
            # Default to /ml/models/
            self.registry_dir = Path(__file__).resolve().parent.parent.parent / "models"
        self.registry_dir.mkdir(parents=True, exist_ok=True)
        self.manifest_path = self.registry_dir / "models.json"

    def get_manifest(self) -> dict[str, Any]:
        """Load manifest from models.json or return initialized default."""
        if self.manifest_path.exists():
            try:
                with open(self.manifest_path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception:
                pass
        return self._initialize_default_manifest()

    def register_model(
        self,
        model_id: str,
        version: str,
        filename: str,
        framework: str,
        task: str,
        metrics: dict[str, Any],
        parameters: dict[str, Any] | None = None,
        description: str = "",
    ) -> dict[str, Any]:
        """Register or update a model entry in the manifest."""
        manifest = self.get_manifest()
        file_path = self.registry_dir / filename
        file_hash = compute_file_sha256(file_path)
        file_size_bytes = file_path.stat().st_size if file_path.exists() else 0

        model_entry = {
            "model_id": model_id,
            "version": version,
            "filename": filename,
            "framework": framework,
            "task": task,
            "description": description,
            "sha256": file_hash,
            "size_bytes": file_size_bytes,
            "size_mb": round(file_size_bytes / (1024 * 1024), 3),
            "updated_at": datetime.datetime.now(datetime.UTC).isoformat(),
            "metrics": metrics,
            "parameters": parameters or {},
            "download_url": f"/static/models/{filename}",
        }

        manifest["models"][model_id] = model_entry
        manifest["last_updated"] = datetime.datetime.now(datetime.UTC).isoformat()

        with open(self.manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2)

        return model_entry

    def _initialize_default_manifest(self) -> dict[str, Any]:
        return {
            "registry_version": "1.0.0",
            "last_updated": datetime.datetime.now(datetime.UTC).isoformat(),
            "models": {},
        }
