"""Command-Line Interface (CLI) for dataset lifecycle commands.

Commands:
  seed      - Generate realistic synthetic prices & ingest DB transactions into /data/raw
  validate  - Validate, clean, quarantine outliers, update rolling board & generate DATASET_CARD.md
  export    - Generate privacy-preserved, anonymized ML-ready datasets in /data/exports
  pipeline  - Run full end-to-end data lifecycle
"""

import argparse
import csv
import json
import sys
from pathlib import Path

# Ensure repository paths are importable regardless of invocation directory
current_file = Path(__file__).resolve()
backend_dir = current_file.parent.parent.parent
repo_root = backend_dir.parent

if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from app.data_pipeline.anonymizer import DataAnonymizer  # noqa: E402
from app.data_pipeline.cleaner import DataCleaner  # noqa: E402
from app.data_pipeline.dataset_card import DatasetCardGenerator  # noqa: E402
from app.data_pipeline.generator import DatasetGenerator  # noqa: E402
from app.data_pipeline.schemas import RawPriceObservation  # noqa: E402
from app.data_pipeline.updater import RollingBoardUpdater  # noqa: E402
from app.data_pipeline.validator import DataValidator  # noqa: E402


def get_data_dirs() -> dict[str, Path]:
    data_root = repo_root / "data"
    dirs = {
        "root": data_root,
        "raw": data_root / "raw",
        "processed": data_root / "processed",
        "quarantine": data_root / "quarantine",
        "exports": data_root / "exports",
        "docs": repo_root / "docs",
    }
    for d in dirs.values():
        d.mkdir(parents=True, exist_ok=True)
    return dirs


def cmd_seed(args: argparse.Namespace) -> Path:
    dirs = get_data_dirs()
    count = getattr(args, "count", 600)
    days = getattr(args, "days", 90)

    print(
        f"Generating {count} realistic synthetic prices across Maharashtra districts "
        f"({days} days history)..."
    )
    records = DatasetGenerator.generate_synthetic_stream(
        count=count,
        days_history=days,
        seed=getattr(args, "seed", 42),
        inject_outliers=True,
    )

    out_file = dirs["raw"] / "raw_prices_latest.json"
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump([r.model_dump(mode="json") for r in records], f, indent=2, ensure_ascii=False)

    print(f"Successfully generated {len(records)} observations -> {out_file}")
    return out_file


def cmd_validate(args: argparse.Namespace) -> None:
    dirs = get_data_dirs()
    raw_file = dirs["raw"] / "raw_prices_latest.json"

    if not raw_file.exists():
        print("Raw data not found. Triggering seed generation first...")
        raw_file = cmd_seed(args)

    with open(raw_file, encoding="utf-8") as f:
        raw_data = json.load(f)

    raw_records = [RawPriceObservation(**item) for item in raw_data]
    print(f"Loaded {len(raw_records)} raw records from {raw_file}")

    # 1. Validation Stage
    validator = DataValidator(quarantine_dir=dirs["quarantine"])
    valid_records, val_quarantined = validator.validate_batch(raw_records, persist_quarantine=True)
    print(
        f"Validation: {len(valid_records)} passed, "
        f"{len(val_quarantined)} quarantined to {dirs['quarantine']}"
    )

    # 2. Cleaning & Normalization Stage
    cleaner = DataCleaner(quarantine_dir=dirs["quarantine"])
    cleaned_records, clean_quarantined = cleaner.clean_batch(valid_records)
    print(
        f"Cleaning: {len(cleaned_records)} cleaned & normalized, "
        f"{len(clean_quarantined)} outliers quarantined"
    )

    # Save cleaned dataset
    cleaned_file = dirs["processed"] / "cleaned_prices_latest.json"
    with open(cleaned_file, "w", encoding="utf-8") as f:
        json.dump(
            [c.model_dump(mode="json") for c in cleaned_records],
            f,
            indent=2,
            ensure_ascii=False,
        )
    print(f"Cleaned dataset saved -> {cleaned_file}")

    # 3. Rolling Board Aggregation
    rolling_rates = RollingBoardUpdater.compute_rolling_board(cleaned_records)
    board_file = dirs["processed"] / "rolling_board_latest.json"
    with open(board_file, "w", encoding="utf-8") as f:
        json.dump(
            [b.model_dump(mode="json") for b in rolling_rates],
            f,
            indent=2,
            ensure_ascii=False,
        )
    print(f"Rolling price board computed ({len(rolling_rates)} combinations) -> {board_file}")

    # 4. Data Quality Evaluation
    metrics = RollingBoardUpdater.evaluate_quality_metrics(
        total_raw=len(raw_records),
        quarantined_val=len(val_quarantined),
        quarantined_clean=len(clean_quarantined),
        cleaned_records=cleaned_records,
    )
    metrics_file = dirs["processed"] / "quality_metrics_latest.json"
    with open(metrics_file, "w", encoding="utf-8") as f:
        json.dump(metrics.model_dump(mode="json"), f, indent=2, ensure_ascii=False)
    print(
        f"Quality Score: {metrics.overall_quality_score}/100 "
        f"(Validity: {metrics.validity_rate_pct}%, Freshness: {metrics.freshness_score}/100)"
    )

    # 5. Generate DATASET_CARD.md
    card_path = DatasetCardGenerator.generate_card(
        cleaned_records=cleaned_records,
        rolling_rates=rolling_rates,
        metrics=metrics,
        output_path=dirs["docs"] / "DATASET_CARD.md",
    )
    print(f"Generated living dataset documentation -> {card_path}")


def cmd_export(args: argparse.Namespace) -> None:
    dirs = get_data_dirs()
    cleaned_file = dirs["processed"] / "cleaned_prices_latest.json"

    if not cleaned_file.exists():
        print("Cleaned dataset not found. Running validation & cleaning first...")
        cmd_validate(args)

    with open(cleaned_file, encoding="utf-8") as f:
        cleaned_data = json.load(f)

    from app.data_pipeline.schemas import CleanedPriceObservation

    cleaned_records = [CleanedPriceObservation(**item) for item in cleaned_data]

    # Anonymize
    anonymizer = DataAnonymizer()
    anonymized = anonymizer.anonymize_batch(cleaned_records)

    # 1. Export JSON
    json_path = dirs["exports"] / "anonymized_prices_latest.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(
            [a.model_dump(mode="json") for a in anonymized],
            f,
            indent=2,
            ensure_ascii=False,
        )

    # 2. Export CSV
    csv_path = dirs["exports"] / "anonymized_prices_latest.csv"
    if anonymized:
        fieldnames = list(anonymized[0].model_dump(mode="json").keys())
        with open(csv_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for row in anonymized:
                writer.writerow(row.model_dump(mode="json"))

    print(f"Exported {len(anonymized)} privacy-preserved records:")
    print(f" - JSON: {json_path}")
    print(f" - CSV:  {csv_path}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Kabadiwala Connect Data Pipeline CLI",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", help="Pipeline subcommands")

    # seed
    parser_seed = subparsers.add_parser("seed", help="Generate synthetic price records")
    parser_seed.add_argument("--count", type=int, default=600, help="Number of records to generate")
    parser_seed.add_argument("--days", type=int, default=90, help="Days of history to simulate")
    parser_seed.add_argument("--seed", type=int, default=42, help="Random seed for reproducibility")

    # validate
    subparsers.add_parser("validate", help="Validate, clean, quarantine, and update dataset card")

    # export
    subparsers.add_parser("export", help="Anonymize and export ML-ready datasets")

    # pipeline
    subparsers.add_parser("pipeline", help="Run full pipeline: seed, validate, and export")

    args = parser.parse_args()

    if args.command == "seed":
        cmd_seed(args)
    elif args.command == "validate":
        cmd_validate(args)
    elif args.command == "export":
        cmd_export(args)
    elif args.command == "pipeline" or not args.command:
        print("=== Running Complete E-Waste Data Lifecycle Pipeline ===")
        cmd_seed(args)
        cmd_validate(args)
        cmd_export(args)
        print("=== Data Lifecycle Pipeline Complete ===")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
