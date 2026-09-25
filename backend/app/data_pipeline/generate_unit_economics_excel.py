"""Generate interactive Excel workbook for Kabadiwala Connect Unit Economics.

Creates:
  /docs/unit_economics.xlsx
With:
  - Assumptions sheet (all parameters editable, with "Fill from Field" tags)
  - Collector Economics sheet (dynamic Excel formulas for Baseline, Conservative, Base, Optimistic)
  - Platform Sustainability sheet (Revenue streams, OPEX, Break-Even, Sensitivity Analysis)
  - Auto-generated openpyxl BarChart for sensitivity visual
"""

from pathlib import Path
import openpyxl
from openpyxl.chart import BarChart, Reference
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter


def build_unit_economics_workbook(output_file: Path) -> None:
    wb = openpyxl.Workbook()
    # Remove default sheet
    wb.remove(wb.active)

    # Styling Palette
    header_fill = PatternFill(start_color="1E3A8A", end_color="1E3A8A", fill_type="solid")  # Navy Blue
    sub_fill = PatternFill(start_color="047857", end_color="047857", fill_type="solid")  # Forest Green
    gold_fill = PatternFill(start_color="D97706", end_color="D97706", fill_type="solid")  # Amber Gold
    gray_fill = PatternFill(start_color="F1F5F9", end_color="F1F5F9", fill_type="solid")
    highlight_fill = PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid")
    warning_fill = PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid")

    font_title = Font(name="Calibri", size=15, bold=True, color="FFFFFF")
    font_header = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
    font_bold = Font(name="Calibri", size=11, bold=True)
    font_regular = Font(name="Calibri", size=11)
    font_italic_gray = Font(name="Calibri", size=10, italic=True, color="475569")

    thin_border = Border(
        left=Side(style="thin", color="CBD5E1"),
        right=Side(style="thin", color="CBD5E1"),
        top=Side(style="thin", color="CBD5E1"),
        bottom=Side(style="thin", color="CBD5E1"),
    )
    thick_bottom = Border(
        left=Side(style="thin", color="CBD5E1"),
        right=Side(style="thin", color="CBD5E1"),
        top=Side(style="thin", color="CBD5E1"),
        bottom=Side(style="medium", color="1E3A8A"),
    )

    # -------------------------------------------------------------------------
    # SHEET 1: ASSUMPTIONS
    # -------------------------------------------------------------------------
    ws_assump = wb.create_sheet(title="Assumptions")
    ws_assump.views.sheetView[0].showGridLines = True

    # Title Banner
    ws_assump.merge_cells("A1:G1")
    cell_a1 = ws_assump["A1"]
    cell_a1.value = "Kabadiwala Connect: Unit Economics & Model Assumptions"
    cell_a1.font = font_title
    cell_a1.fill = header_fill
    cell_a1.alignment = Alignment(horizontal="center", vertical="center")
    ws_assump.row_dimensions[1].height = 40

    ws_assump.append([])
    ws_assump.append([
        "Parameter / Scrap Category",
        "Baseline Daily Volume (kg)",
        "Informal Middleman Rate (₹/kg)",
        "Formal Recycler Benchmark (₹/kg)",
        "Middleman Haircut (%)",
        "Data Provenance / Status",
        "Fill from Field Action (Collector Interviews)",
    ])
    
    # Headers styling
    for col in range(1, 8):
        c = ws_assump.cell(row=3, column=col)
        c.font = font_header
        c.fill = sub_fill
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
    ws_assump.row_dimensions[3].height = 28

    # Category Assumptions Data
    cat_data = [
        ("CRT Monitors / TVs", 8.0, 9.50, 13.50, "Assumption", "Replace with measured daily kg from Interview #1"),
        ("LCD Panels & Assemblies", 4.0, 32.00, 46.00, "Assumption", "Verify screen buying rate from scrap yard visits"),
        ("PCB (Low Grade - Power Supplies)", 5.0, 35.00, 50.00, "Assumption", "Replace with local aggregator quote"),
        ("PCB (Mid Grade - Motherboards)", 3.0, 145.00, 205.00, "Field-Verified (Thane)", "Cross-check with Thane field baseline"),
        ("PCB (High Grade - Mobile/Server)", 1.5, 420.00, 610.00, "Field-Verified (Kurla)", "Verify against formal smelter lot quote"),
        ("Copper Cables & Wiring", 6.0, 215.00, 305.00, "Field-Verified (Dharavi)", "Record actual unstripped cable price"),
        ("Li-ion & Lead-Acid Batteries", 4.5, 65.00, 92.00, "Assumption", "Verify hazardous battery rate"),
        ("Motors, Transformers & Magnets", 6.0, 58.00, 82.00, "Assumption", "Verify copper recovery deductions"),
        ("Mixed E-Waste Plastics (ABS/HIPS)", 5.0, 15.00, 23.00, "Assumption", "Confirm clean sorted plastic price"),
    ]

    row_idx = 4
    for item in cat_data:
        name, vol, inf_price, form_price, prov, action = item
        haircut_formula = f"=(D{row_idx}-C{row_idx})/D{row_idx}"
        ws_assump.append([name, vol, inf_price, form_price, haircut_formula, prov, action])
        
        ws_assump.cell(row=row_idx, column=1).font = font_bold
        ws_assump.cell(row=row_idx, column=2).number_format = "0.0"
        ws_assump.cell(row=row_idx, column=3).number_format = "₹#,##0.00"
        ws_assump.cell(row=row_idx, column=4).number_format = "₹#,##0.00"
        ws_assump.cell(row=row_idx, column=5).number_format = "0.0%"
        ws_assump.cell(row=row_idx, column=6).font = font_italic_gray
        ws_assump.cell(row=row_idx, column=7).fill = warning_fill

        for col in range(1, 8):
            ws_assump.cell(row=row_idx, column=col).border = thin_border
        row_idx += 1

    # Totals row for Baseline Volume
    ws_assump.append([
        "Total Daily E-Waste Collected (kg)",
        f"=SUM(B4:B{row_idx-1})",
        "-",
        "-",
        "-",
        "-",
        "Total daily collection capacity",
    ])
    tot_row = row_idx
    ws_assump.cell(row=tot_row, column=1).font = font_bold
    ws_assump.cell(row=tot_row, column=2).font = font_bold
    ws_assump.cell(row=tot_row, column=2).number_format = "0.0 kg"
    for col in range(1, 8):
        ws_assump.cell(row=tot_row, column=col).border = thick_bottom
        ws_assump.cell(row=tot_row, column=col).fill = gray_fill

    # Operational Parameters Section
    row_idx += 3
    ws_assump.cell(row=row_idx, column=1, value="General Operational Assumptions").font = font_bold
    ws_assump.cell(row=row_idx, column=1).fill = gold_fill
    ws_assump.cell(row=row_idx, column=1).font = font_header
    ws_assump.merge_cells(f"A{row_idx}:G{row_idx}")
    row_idx += 1

    op_params = [
        ("Working Days per Month", 26, "Days", "Assumption", "Confirm actual working days from interview"),
        ("Monthly Informal Health & Fines Burden", 850, "₹ / month", "Assumption", "Cost of burn treatments, toxic cough syrup & police fines"),
        ("Conservative Price Improvement", 0.10, "%", "Scenario Assumption", "Platform gain: 10% price lift"),
        ("Conservative Volume Increase", 0.20, "%", "Scenario Assumption", "Platform gain: 20% volume growth (pickup routing)"),
        ("Base Price Improvement", 0.25, "%", "Scenario Assumption", "Platform gain: 25% price lift"),
        ("Base Volume Increase", 0.40, "%", "Scenario Assumption", "Platform gain: 40% volume growth"),
        ("Optimistic Price Improvement", 0.35, "%", "Scenario Assumption", "Platform gain: 35% price lift"),
        ("Optimistic Volume Increase", 0.60, "%", "Scenario Assumption", "Platform gain: 60% volume growth"),
    ]

    for p_name, val, unit, prov, action in op_params:
        ws_assump.append([p_name, val, unit, "", "", prov, action])
        ws_assump.cell(row=row_idx, column=1).font = font_bold
        if isinstance(val, float):
            ws_assump.cell(row=row_idx, column=2).number_format = "0.0%"
        elif isinstance(val, int):
            ws_assump.cell(row=row_idx, column=2).number_format = "#,##0"
        
        for col in range(1, 8):
            ws_assump.cell(row=row_idx, column=col).border = thin_border
        row_idx += 1

    # Format Column Widths for Assumptions
    for col in ws_assump.columns:
        col_letter = get_column_letter(col[0].column)
        ws_assump.column_dimensions[col_letter].width = 25
    ws_assump.column_dimensions["A"].width = 36
    ws_assump.column_dimensions["G"].width = 44

    # -------------------------------------------------------------------------
    # SHEET 2: COLLECTOR ECONOMICS
    # -------------------------------------------------------------------------
    ws_col = wb.create_sheet(title="Collector Economics")
    ws_col.views.sheetView[0].showGridLines = True

    # Title Banner
    ws_col.merge_cells("A1:H1")
    c_col_a1 = ws_col["A1"]
    c_col_a1.value = "Collector Income Delta: Baseline (Informal) vs Platform Scenarios"
    c_col_a1.font = font_title
    c_col_a1.fill = header_fill
    c_col_a1.alignment = Alignment(horizontal="center", vertical="center")
    ws_col.row_dimensions[1].height = 40

    ws_col.append([])
    ws_col.append([
        "Scrap Category",
        "Baseline Daily (₹)",
        "Conservative Daily (₹)",
        "Base Daily (₹)",
        "Optimistic Daily (₹)",
        "Base Daily Lift (₹)",
        "Base % Lift",
        "Remarks & Impact Drivers",
    ])

    for col in range(1, 9):
        c = ws_col.cell(row=3, column=col)
        c.font = font_header
        c.fill = sub_fill
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
    ws_col.row_dimensions[3].height = 28

    # Category calculation rows (Referencing Assumptions rows 4..12)
    # Baseline Daily = Vol * Informal_Rate = Assumptions!B4 * Assumptions!C4
    # Conservative Daily = (Vol * 1.20) * (Informal_Rate * 1.10)
    # Base Daily = (Vol * 1.40) * (Informal_Rate * 1.25)
    # Optimistic Daily = (Vol * 1.60) * (Informal_Rate * 1.35)

    c_row = 4
    for i in range(4, 13):
        cat_ref = f"Assumptions!A{i}"
        base_calc = f"=Assumptions!B{i}*Assumptions!C{i}"
        cons_calc = f"=(Assumptions!B{i}*(1+Assumptions!$B$19))*(Assumptions!C{i}*(1+Assumptions!$B$18))"
        base_scen_calc = f"=(Assumptions!B{i}*(1+Assumptions!$B$21))*(Assumptions!C{i}*(1+Assumptions!$B$20))"
        opt_calc = f"=(Assumptions!B{i}*(1+Assumptions!$B$23))*(Assumptions!C{i}*(1+Assumptions!$B$22))"
        lift_calc = f"=D{c_row}-B{c_row}"
        pct_lift = f"=F{c_row}/B{c_row}"

        ws_col.append([
            f"={cat_ref}",
            base_calc,
            cons_calc,
            base_scen_calc,
            opt_calc,
            lift_calc,
            pct_lift,
            "Direct formal market rate without middleman haircut",
        ])

        ws_col.cell(row=c_row, column=1).font = font_bold
        for col_idx in [2, 3, 4, 5, 6]:
            ws_col.cell(row=c_row, column=col_idx).number_format = "₹#,##0.00"
        ws_col.cell(row=c_row, column=7).number_format = "+0.0%"
        ws_col.cell(row=c_row, column=7).fill = highlight_fill
        ws_col.cell(row=c_row, column=8).font = font_italic_gray

        for col in range(1, 9):
            ws_col.cell(row=c_row, column=col).border = thin_border
        c_row += 1

    # Daily Totals Row
    ws_col.append([
        "TOTAL DAILY GROSS EARNINGS (₹)",
        f"=SUM(B4:B{c_row-1})",
        f"=SUM(C4:C{c_row-1})",
        f"=SUM(D4:D{c_row-1})",
        f"=SUM(E4:E{c_row-1})",
        f"=D{c_row}-B{c_row}",
        f"=(D{c_row}-B{c_row})/B{c_row}",
        "Net daily earnings across all categories",
    ])
    daily_tot_row = c_row
    ws_col.cell(row=daily_tot_row, column=1).font = font_bold
    for col_idx in range(1, 9):
        ws_col.cell(row=daily_tot_row, column=col_idx).border = thick_bottom
        ws_col.cell(row=daily_tot_row, column=col_idx).fill = gray_fill
        if col_idx in [2, 3, 4, 5, 6]:
            ws_col.cell(row=daily_tot_row, column=col_idx).number_format = "₹#,##0.00"
            ws_col.cell(row=daily_tot_row, column=col_idx).font = font_bold
    ws_col.cell(row=daily_tot_row, column=7).number_format = "+0.0%"
    ws_col.cell(row=daily_tot_row, column=7).font = font_bold
    ws_col.cell(row=daily_tot_row, column=7).fill = highlight_fill

    # Monthly Summary Section (26 working days)
    c_row += 3
    ws_col.cell(row=c_row, column=1, value="Monthly Collector Income & Living Standard Comparison").font = font_header
    ws_col.cell(row=c_row, column=1).fill = header_fill
    ws_col.merge_cells(f"A{c_row}:H{c_row}")
    c_row += 1

    monthly_headers = [
        "Metric",
        "Baseline (Informal)",
        "Conservative (Platform)",
        "Base Case (Platform)",
        "Optimistic (Platform)",
        "Base Monthly Delta",
        "Growth %",
        "Economic & Social Impact",
    ]
    ws_col.append(monthly_headers)
    for col in range(1, 9):
        c = ws_col.cell(row=c_row, column=col)
        c.font = font_header
        c.fill = sub_fill
        c.alignment = Alignment(horizontal="center", vertical="center")
    c_row += 1

    # Monthly rows
    # 1. Gross Revenue = Daily * 26
    m_rev_row = c_row
    ws_col.append([
        "Monthly Gross Scrap Revenue (26 Days)",
        f"=B{daily_tot_row}*Assumptions!$B$16",
        f"=C{daily_tot_row}*Assumptions!$B$16",
        f"=D{daily_tot_row}*Assumptions!$B$16",
        f"=E{daily_tot_row}*Assumptions!$B$16",
        f"=D{m_rev_row}-B{m_rev_row}",
        f"=(D{m_rev_row}-B{m_rev_row})/B{m_rev_row}",
        "Calculated from 26 working collection days per month",
    ])
    c_row += 1

    # 2. Health & Police Fines Burden
    m_cost_row = c_row
    ws_col.append([
        "Less: Health, Burn Injuries & Fine Burden",
        f"=-Assumptions!$B$17",
        f"=-Assumptions!$B$17*0.4",
        f"=-Assumptions!$B$17*0.2",
        f"=0",
        f"=D{m_cost_row}-B{m_cost_row}",
        f"=(D{m_cost_row}-B{m_cost_row})/(-B{m_cost_row})",
        "Safety instructions & formal channels eliminate backyard acid/fire risks",
    ])
    c_row += 1

    # 3. Net Monthly Income = Gross - Health/Fines
    m_net_row = c_row
    ws_col.append([
        "NET MONTHLY TAKE-HOME INCOME (₹)",
        f"=B{m_rev_row}+B{m_cost_row}",
        f"=C{m_rev_row}+C{m_cost_row}",
        f"=D{m_rev_row}+D{m_cost_row}",
        f"=E{m_rev_row}+E{m_cost_row}",
        f"=D{m_net_row}-B{m_net_row}",
        f"=(D{m_net_row}-B{m_net_row})/B{m_net_row}",
        "Transformative income lift lifting collector families above poverty line",
    ])

    for r_idx in [m_rev_row, m_cost_row, m_net_row]:
        ws_col.cell(row=r_idx, column=1).font = font_bold
        for c_idx in [2, 3, 4, 5, 6]:
            ws_col.cell(row=r_idx, column=c_idx).number_format = "₹#,##0.00"
            ws_col.cell(row=r_idx, column=c_idx).border = thin_border
        ws_col.cell(row=r_idx, column=7).number_format = "+0.0%"
        ws_col.cell(row=r_idx, column=7).fill = highlight_fill
        ws_col.cell(row=r_idx, column=8).font = font_italic_gray
        for col in range(1, 9):
            ws_col.cell(row=r_idx, column=col).border = thin_border

    ws_col.cell(row=m_net_row, column=1).fill = gold_fill
    ws_col.cell(row=m_net_row, column=1).font = font_title
    for col in range(1, 9):
        ws_col.cell(row=m_net_row, column=col).border = thick_bottom

    # Add Chart: Net Monthly Income by Scenario
    chart1 = BarChart()
    chart1.type = "col"
    chart1.style = 10
    chart1.title = "Collector Net Monthly Income: Baseline vs Platform Scenarios (₹/month)"
    chart1.y_axis.title = "Net Income (₹)"
    chart1.x_axis.title = "Scenarios"
    chart1.width = 16
    chart1.height = 10

    data = Reference(ws_col, min_col=2, min_row=m_net_row, max_col=5, max_row=m_net_row)
    cats = Reference(ws_col, min_col=2, min_row=m_rev_row-1, max_col=5, max_row=m_rev_row-1)
    chart1.add_data(data, from_rows=True, titles_from_data=False)
    chart1.set_categories(cats)
    chart1.legend = None
    ws_col.add_chart(chart1, "B25")

    # Column Widths for Collector Economics
    for col in ws_col.columns:
        col_letter = get_column_letter(col[0].column)
        ws_col.column_dimensions[col_letter].width = 22
    ws_col.column_dimensions["A"].width = 38
    ws_col.column_dimensions["H"].width = 46

    # -------------------------------------------------------------------------
    # SHEET 3: PLATFORM SUSTAINABILITY
    # -------------------------------------------------------------------------
    ws_plat = wb.create_sheet(title="Platform Sustainability")
    ws_plat.views.sheetView[0].showGridLines = True

    # Title Banner
    ws_plat.merge_cells("A1:G1")
    p_a1 = ws_plat["A1"]
    p_a1.value = "Platform Unit Economics, Revenue Streams & Break-Even Model"
    p_a1.font = font_title
    p_a1.fill = header_fill
    p_a1.alignment = Alignment(horizontal="center", vertical="center")
    ws_plat.row_dimensions[1].height = 40

    ws_plat.append([])
    ws_plat.append([
        "Revenue Stream / Cost Driver",
        "Unit Rate / Basis",
        "Monthly Volume Units",
        "Monthly Revenue / Cost (₹)",
        "% of Total",
        "Provenance / Status",
        "Model Notes & Scaling Assumption",
    ])

    for col in range(1, 8):
        c = ws_plat.cell(row=3, column=col)
        c.font = font_header
        c.fill = sub_fill
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
    ws_plat.row_dimensions[3].height = 28

    # Revenue Stream Lines
    p_row = 4
    rev_streams = [
        ("1. Recycler SaaS Portal Subscription", 500.0, "₹ / recycler / mo", 100, "=B4*D4", "Assumption", "100 authorized EPR aggregators across Maharashtra"),
        ("2. Marketplace Transaction Commission", 0.015, "1.5% of gross trade", 5850000.0, "=B5*D5", "Assumption", "Gross transaction volume of ~130 MT/mo across 1,000 collectors"),
        ("3. EPR Compliance Traceability Certificate Fee", 1.20, "₹ / verified kg", 130000.0, "=B6*D6", "Assumption", "Brand Producer EPR compliance credits (CPCB verified portal)"),
        ("4. Government / CSR Innovation & Safety Grant", 25000.0, "₹ / month fixed", 1, "=B7*D7", "Assumption", "Ministry of Mines / JNARDDC informal sector formalization grant"),
    ]

    for name, rate, basis, vol, formula, prov, notes in rev_streams:
        ws_plat.append([name, rate, basis, vol, formula, prov, notes])
        ws_plat.cell(row=p_row, column=1).font = font_bold
        if isinstance(rate, float) and rate < 1.0:
            ws_plat.cell(row=p_row, column=2).number_format = "0.0%"
        else:
            ws_plat.cell(row=p_row, column=2).number_format = "₹#,##0.00"
        
        ws_plat.cell(row=p_row, column=4).number_format = "#,##0"
        ws_plat.cell(row=p_row, column=5).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=6).font = font_italic_gray
        for col in range(1, 8):
            ws_plat.cell(row=p_row, column=col).border = thin_border
        p_row += 1

    # Total Monthly Revenue
    tot_rev_row = p_row
    ws_plat.append([
        "TOTAL MONTHLY REVENUE (₹)",
        "-",
        "-",
        "-",
        f"=SUM(E4:E{tot_rev_row-1})",
        "100.0%",
        "Total blended platform revenue",
    ])
    ws_plat.cell(row=tot_rev_row, column=1).font = font_bold
    ws_plat.cell(row=tot_rev_row, column=5).font = font_bold
    ws_plat.cell(row=tot_rev_row, column=5).number_format = "₹#,##0.00"
    ws_plat.cell(row=tot_rev_row, column=5).fill = highlight_fill
    for col in range(1, 8):
        ws_plat.cell(row=tot_rev_row, column=col).border = thick_bottom
        ws_plat.cell(row=tot_rev_row, column=col).fill = gray_fill
    p_row += 2

    # Cost Driver Section (OPEX)
    ws_plat.cell(row=p_row, column=1, value="Monthly Operational Cost Structure (OPEX)").font = font_header
    ws_plat.cell(row=p_row, column=1).fill = header_fill
    ws_plat.merge_cells(f"A{p_row}:G{p_row}")
    p_row += 1

    cost_start_row = p_row
    costs = [
        ("Cloud Infrastructure (PostGIS, FastAPI, Next.js Hosting)", 8500.0, "Monthly AWS/GCP hosting", "Assumption", "High availability, spatial indexing & auto-scaling"),
        ("SMS OTP & Vernacular Speech Engine API", 3500.0, "Monthly API quota", "Assumption", "Pluggable OTP verification & high-quality Devanagari TTS"),
        ("Ground Field Coordinators & Recycler Support (2 Staff)", 50000.0, "Staff honorarium", "Assumption", "Scrap cluster outreach, weight verification audits & onboarding"),
        ("Software Maintenance, ML Drift Retraining & Bugfixes", 25000.0, "Dev team allocation", "Assumption", "Monthly retraining of pricing & anomaly detection pipelines"),
        ("EPR Regulatory Audit & Compliance Certification Filing", 12000.0, "Auditor compliance", "Assumption", "Annual third-party mass balance validation"),
    ]

    for c_name, c_amt, c_basis, prov, notes in costs:
        ws_plat.append([c_name, c_amt, c_basis, 1, f"=B{p_row}", prov, notes])
        ws_plat.cell(row=p_row, column=1).font = font_bold
        ws_plat.cell(row=p_row, column=2).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=5).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=6).font = font_italic_gray
        for col in range(1, 8):
            ws_plat.cell(row=p_row, column=col).border = thin_border
        p_row += 1

    # Total Monthly OPEX
    tot_cost_row = p_row
    ws_plat.append([
        "TOTAL MONTHLY OPERATIONAL COSTS (₹)",
        "-",
        "-",
        "-",
        f"=SUM(E{cost_start_row}:E{tot_cost_row-1})",
        "-",
        "Total monthly operating budget",
    ])
    ws_plat.cell(row=tot_cost_row, column=1).font = font_bold
    ws_plat.cell(row=tot_cost_row, column=5).font = font_bold
    ws_plat.cell(row=tot_cost_row, column=5).number_format = "₹#,##0.00"
    for col in range(1, 8):
        ws_plat.cell(row=tot_cost_row, column=col).border = thick_bottom
        ws_plat.cell(row=tot_cost_row, column=col).fill = gray_fill
    p_row += 2

    # Net Operating Margin
    net_plat_row = p_row
    ws_plat.append([
        "NET MONTHLY OPERATING MARGIN / SURPLUS (₹)",
        "-",
        "-",
        "-",
        f"=E{tot_rev_row}-E{tot_cost_row}",
        f"=(E{tot_rev_row}-E{tot_cost_row})/E{tot_rev_row}",
        "Sustainable unit economics for long-term nationwide deployment",
    ])
    ws_plat.cell(row=net_plat_row, column=1).font = font_title
    ws_plat.cell(row=net_plat_row, column=1).fill = gold_fill
    ws_plat.cell(row=net_plat_row, column=5).font = font_bold
    ws_plat.cell(row=net_plat_row, column=5).number_format = "₹#,##0.00"
    ws_plat.cell(row=net_plat_row, column=5).fill = highlight_fill
    ws_plat.cell(row=net_plat_row, column=6).font = font_bold
    ws_plat.cell(row=net_plat_row, column=6).number_format = "0.0%"
    for col in range(1, 8):
        ws_plat.cell(row=net_plat_row, column=col).border = thick_bottom

    # Sensitivity Analysis Section: Recycler Adoption Rate
    p_row += 3
    ws_plat.cell(row=p_row, column=1, value="Sensitivity Analysis: Recycler Adoption Pace (Year 1 Scenarios)").font = font_header
    ws_plat.cell(row=p_row, column=1).fill = header_fill
    ws_plat.merge_cells(f"A{p_row}:G{p_row}")
    p_row += 1

    sens_headers = [
        "Adoption Scenario",
        "Active Recyclers",
        "Monthly Volume (kg)",
        "Monthly Revenue (₹)",
        "Monthly OPEX (₹)",
        "Net Surplus / (Deficit) (₹)",
        "Status & Breakeven Point",
    ]
    ws_plat.append(sens_headers)
    for col in range(1, 8):
        c = ws_plat.cell(row=p_row, column=col)
        c.font = font_header
        c.fill = sub_fill
        c.alignment = Alignment(horizontal="center", vertical="center")
    p_row += 1

    sens_cases = [
        ("Slow Adoption (Year 1 Cold Start)", 20, 26000.0, "=(20*500)+(26000*45*0.015)+(26000*1.2)+25000", f"=E{tot_cost_row}*0.8", "Breakeven via Grant Support"),
        ("Moderate Adoption (Mid Year 1)", 50, 65000.0, "=(50*500)+(65000*45*0.015)+(65000*1.2)+25000", f"=E{tot_cost_row}*0.9", "Profitable Operations"),
        ("Target Adoption (Year 1 Goal)", 100, 130000.0, f"=E{tot_rev_row}", f"=E{tot_cost_row}", "Target Operating Model"),
        ("High Expansion (Year 2 Scale)", 250, 350000.0, "=(250*500)+(350000*45*0.015)+(350000*1.2)+25000", f"=E{tot_cost_row}*1.4", "High Surplus for Collector Welfare Fund"),
    ]

    for s_name, rec_cnt, vol, rev_f, opex_f, stat in sens_cases:
        surp_f = f"=D{p_row}-E{p_row}"
        ws_plat.append([s_name, rec_cnt, vol, rev_f, opex_f, surp_f, stat])
        ws_plat.cell(row=p_row, column=1).font = font_bold
        ws_plat.cell(row=p_row, column=2).number_format = "#,##0"
        ws_plat.cell(row=p_row, column=3).number_format = "#,##0 kg"
        ws_plat.cell(row=p_row, column=4).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=5).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=6).number_format = "₹#,##0.00"
        ws_plat.cell(row=p_row, column=6).font = font_bold
        ws_plat.cell(row=p_row, column=7).font = font_italic_gray
        for col in range(1, 8):
            ws_plat.cell(row=p_row, column=col).border = thin_border
        p_row += 1

    # Column Widths for Platform Sustainability
    for col in ws_plat.columns:
        col_letter = get_column_letter(col[0].column)
        ws_plat.column_dimensions[col_letter].width = 24
    ws_plat.column_dimensions["A"].width = 44
    ws_plat.column_dimensions["G"].width = 46

    # Save output file
    output_file.parent.mkdir(parents=True, exist_ok=True)
    wb.save(output_file)
    print(f"[EXCEL GENERATED] Successfully generated {output_file}")


if __name__ == "__main__":
    out = Path(__file__).resolve().parent.parent.parent.parent / "docs" / "unit_economics.xlsx"
    build_unit_economics_workbook(out)
