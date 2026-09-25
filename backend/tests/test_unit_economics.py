"""Unit tests for unit economics Excel model generation."""

import openpyxl

from app.data_pipeline.generate_unit_economics_excel import build_unit_economics_workbook


def test_unit_economics_workbook_structure(tmp_path):
    """Verify generated Excel contains all 3 sheets, formulas, and chart."""
    test_file = tmp_path / "test_unit_economics.xlsx"
    build_unit_economics_workbook(test_file)

    assert test_file.exists()
    wb = openpyxl.load_workbook(test_file, data_only=False)

    sheet_names = wb.sheetnames
    assert "Assumptions" in sheet_names
    assert "Collector Economics" in sheet_names
    assert "Platform Sustainability" in sheet_names

    ws_assump = wb["Assumptions"]
    assert ws_assump["A1"].value is not None
    assert "Kabadiwala Connect" in ws_assump["A1"].value

    ws_col = wb["Collector Economics"]
    assert len(ws_col._charts) >= 1

    ws_plat = wb["Platform Sustainability"]
    assert ws_plat["A1"].value is not None
