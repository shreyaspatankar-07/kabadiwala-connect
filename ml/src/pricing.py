"""Baseline pricing estimate functions for e-waste categories."""

CATEGORY_BASE_RATES: dict[str, float] = {
    "pcb_grade_a": 150.0,
    "pcb_grade_b": 90.0,
    "pcb_grade_c": 45.0,
    "lithium_ion_battery": 200.0,
    "crt_monitor": 25.0,
    "flat_display": 70.0,
    "copper_cable_heavy": 380.0,
    "mixed_e_waste": 30.0,
}


def estimate_lot_value(category: str, weight_kg: float) -> float:
    """Calculate the estimated total INR value for a given lot category and weight."""
    if weight_kg < 0:
        raise ValueError("Weight cannot be negative.")
    base_rate = CATEGORY_BASE_RATES.get(category, 0.0)
    return round(base_rate * weight_kg, 2)
