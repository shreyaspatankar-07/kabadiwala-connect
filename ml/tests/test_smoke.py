import pytest

from src.pricing import estimate_lot_value


def test_estimate_lot_value_valid():
    val = estimate_lot_value("pcb_grade_a", 10.0)
    assert val == 1500.0


def test_estimate_lot_value_unknown_category():
    val = estimate_lot_value("unknown_item", 5.0)
    assert val == 0.0


def test_estimate_lot_value_negative_weight():
    with pytest.raises(ValueError):
        estimate_lot_value("pcb_grade_a", -2.0)
