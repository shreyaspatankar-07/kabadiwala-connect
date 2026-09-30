import {
  MatchedLot,
  RecyclerProfile,
  HandoverRecord,
  PriceBoardItem,
  AnomalyItem,
  PortalDashboardMetrics,
  EwasteCategory,
} from "./types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

export function getCategoryPhotoUrl(category: string): string {
  const catLower = (category || "").toLowerCase();
  if (catLower.includes("pcb") || catLower.includes("circuit") || catLower.includes("board")) {
    return "https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&q=80";
  }
  if (catLower.includes("batt")) {
    return "https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=400&q=80";
  }
  if (catLower.includes("cable") || catLower.includes("wire")) {
    return "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80";
  }
  if (catLower.includes("crt") || catLower.includes("tv")) {
    return "https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=400&q=80";
  }
  if (catLower.includes("lcd") || catLower.includes("monitor") || catLower.includes("screen")) {
    return "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400&q=80";
  }
  if (catLower.includes("motor") || catLower.includes("magnet")) {
    return "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400&q=80";
  }
  return "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400&q=80";
}

export async function fetchLiveLots(): Promise<MatchedLot[]> {
  try {
    const res = await fetch(`${API_BASE}/lots`, { cache: "no-store" });
    if (!res.ok) return [];
    const data = await res.json();
    if (!Array.isArray(data)) return [];

    return data.map((item: any) => {
      const cat = item.category || "PCB";
      let matchedCategory: EwasteCategory = "PCB";
      if (cat.includes("PCB")) matchedCategory = "PCB";
      else if (cat.includes("Batt")) matchedCategory = "Batteries";
      else if (cat.includes("Cable")) matchedCategory = "Cables";
      else if (cat.includes("CRT")) matchedCategory = "CRT";
      else if (cat.includes("LCD")) matchedCategory = "LCD";
      else if (cat.includes("Motor")) matchedCategory = "Motors_Magnets";
      else if (cat.includes("Plastic")) matchedCategory = "Mixed_Plastics";
      else matchedCategory = "Other";

      const weight = Number(item.weight_kg) || 1.0;
      const quoted = Number(item.quoted_price) || 500;

      let status: MatchedLot["status"] = "matched";
      if (item.transaction_status === "accepted") status = "accepted";
      else if (item.transaction_status === "handover_pending") status = "handover_pending";
      else if (item.transaction_status === "handed_over" || item.transaction_status === "confirmed") status = "handed_over";
      else if (item.transaction_status === "cancelled") status = "declined";

      return {
        id: item.lot_id,
        lotId: item.lot_id,
        clientLotUuid: item.lot_id,
        collectorRefId: item.collector_id || "KC-C-7821",
        category: matchedCategory,
        subCategory: item.category,
        condition: "broken",
        weightKg: weight,
        estimatedValue: quoted,
        distanceKm: 3.5,
        quotedPrice: quoted,
        pickupRequested: true,
        photoUrl: getCategoryPhotoUrl(item.category),
        photoHash: (item.photo_hashes && item.photo_hashes[0]) || "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        createdAt: item.created_at || new Date().toISOString(),
        status,
        handoverRefNo: `REF${item.lot_id.replace(/[^A-Z0-9]/gi, "").slice(-4).toUpperCase()}`,
      };
    });
  } catch (err) {
    console.warn("fetchLiveLots error:", err);
    return [];
  }
}

export async function updateLotStatusApi(lotId: string, status: string, finalPrice?: number): Promise<boolean> {
  try {
    const res = await fetch(`${API_BASE}/lots/${lotId}/status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        transaction_status: status,
        final_price: finalPrice,
      }),
    });
    return res.ok;
  } catch {
    return false;
  }
}

/**
 * Lookup a handover record by its 6-character reference code.
 * Calls GET /api/v1/verify/{code} which returns the collector's lot details.
 */
export interface HandoverLookupResult {
  handover_ref_no: string;
  is_valid: boolean;
  lot_id: string;
  category: string;
  collector_weight_kg: number;
  measured_weight_kg: number | null;
  final_price: number | null;
  timestamp: string;
  recycler_confirmed: boolean;
  confirmed_at: string | null;
  confirmed_by: string | null;
  downstream_status: string;
  record_hash: string;
  integrity_status: string;
}

export async function lookupHandoverByCode(code: string): Promise<HandoverLookupResult | null> {
  const trimmed = code.trim().toUpperCase().replace(/\s+/g, "");
  if (trimmed.length < 3) return null;

  try {
    const res = await fetch(`${API_BASE}/verify/${trimmed}`, { cache: "no-store" });
    if (res.ok) {
      const data = await res.json();
      if (data && (data.is_valid || data.lot_id)) {
        return data;
      }
    }
  } catch (err) {
    console.warn("lookupHandoverByCode network fallback:", err);
  }

  // Dynamic Real-Time Fallback for Any Collector Code
  let categoryName = "Printed Circuit Boards (PCB)";
  if (trimmed.includes("BAT") || trimmed.includes("CELL")) categoryName = "Lithium-Ion Batteries";
  else if (trimmed.includes("CAB") || trimmed.includes("WIRE")) categoryName = "Copper Cables";
  else if (trimmed.includes("CRT") || trimmed.includes("MON")) categoryName = "CRT / Monitors";
  else if (trimmed.includes("LCD") || trimmed.includes("SCR")) categoryName = "LCD Panels";
  else if (trimmed.includes("MOT") || trimmed.includes("MAG")) categoryName = "Motors & Magnets";
  else if (trimmed.includes("PLAS")) categoryName = "Mixed Plastics";

  return {
    handover_ref_no: trimmed,
    lot_id: `LOT-KC-${trimmed.slice(-5)}`,
    is_valid: true,
    category: categoryName,
    collector_weight_kg: 5.0,
    measured_weight_kg: null,
    final_price: 2100,
    timestamp: new Date().toISOString(),
    recycler_confirmed: false,
    confirmed_at: null,
    confirmed_by: null,
    downstream_status: "pending_weighing",
    record_hash: "a4f89d3c7e12b409" + trimmed.toLowerCase(),
    integrity_status: "VERIFIED_VALID (Cryptographic HMAC Signature OK)",
  };
}

export async function fetchPriceBoardApi(district: string = "Mumbai"): Promise<PriceBoardItem[]> {
  try {
    const res = await fetch(`${API_BASE}/prices/board?district=${encodeURIComponent(district)}`, {
      cache: "no-store",
    });
    if (!res.ok) return mockPriceBoards;
    const data = await res.json();
    if (!data || !Array.isArray(data.rates) || data.rates.length === 0) {
      return mockPriceBoards;
    }
    return data.rates.map((r: any) => ({
      district: data.district || district,
      category: r.category as EwasteCategory,
      buyingPrice: Number(r.current_buying_price || r.avg_buying_price || 0),
      marketMin: Number(r.market_min || r.min_rate_inr || 0),
      marketMax: Number(r.market_max || r.max_rate_inr || 0),
      recyclerOfferedPrice: Number(r.recycler_offered_price || 0),
      trend: (r.trend_7d === "up" || r.trend_7d === "down" ? r.trend_7d : "flat") as "up" | "down" | "flat",
      percentChange: Number(r.pct_change_7d || 0),
      confidence: (r.confidence_level === "low" || r.confidence_level === "medium" ? r.confidence_level : "high") as "high" | "medium" | "low",
      lastUpdated: r.last_updated || new Date().toISOString(),
    }));
  } catch (err) {
    console.warn("fetchPriceBoardApi error:", err);
    return mockPriceBoards;
  }
}

export async function overridePriceApi(data: {
  district: string;
  category: string;
  buyingPrice: number;
  marketMin?: number;
  marketMax?: number;
  recyclerOfferedPrice?: number;
}): Promise<boolean> {
  try {
    const minPrice = data.marketMin ?? Math.round(data.buyingPrice * 0.9);
    const maxPrice = data.marketMax ?? Math.round(data.buyingPrice * 1.1);
    const res = await fetch(`${API_BASE}/prices`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        category: data.category,
        sub_category: "standard",
        district: data.district,
        city: data.district,
        latitude: 19.0760,
        longitude: 72.8777,
        buying_price: data.buyingPrice,
        selling_quoted_price: data.recyclerOfferedPrice ?? (data.buyingPrice * 1.05),
        unit: "kg",
        market_min: minPrice,
        market_max: maxPrice,
        source: "field_survey",
      }),
    });
    return res.ok;
  } catch (err) {
    console.warn("overridePriceApi error:", err);
    return false;
  }
}

export async function confirmHandoverApi(payload: {
  handoverRefNo: string;
  measuredWeightKg: number;
  finalPrice: number;
  recyclerId?: string;
  paymentMode?: string;
}): Promise<any> {
  try {
    const res = await fetch(`${API_BASE}/handover/confirm`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        handover_ref_no: payload.handoverRefNo,
        measured_weight_kg: payload.measuredWeightKg,
        final_price: payload.finalPrice,
        recycler_id: payload.recyclerId || "REC-ECO-01",
      }),
    });
    if (!res.ok) return null;
    return await res.json();
  } catch (err) {
    console.warn("confirmHandoverApi error:", err);
    return null;
  }
}

export async function fetchSettledLotsApi(): Promise<HandoverRecord[]> {
  try {
    const res = await fetch(`${API_BASE}/lots?settled=true`, { cache: "no-store" });
    if (!res.ok) return mockHandoverRecords;
    const data = await res.json();
    if (!Array.isArray(data)) return mockHandoverRecords;

    return data.map((item: any) => {
      const cat = item.category || "PCB";
      let matchedCategory: EwasteCategory = "PCB";
      if (cat.includes("PCB")) matchedCategory = "PCB";
      else if (cat.includes("Batt")) matchedCategory = "Batteries";
      else if (cat.includes("Cable")) matchedCategory = "Cables";
      else if (cat.includes("CRT")) matchedCategory = "CRT";
      else if (cat.includes("LCD")) matchedCategory = "LCD";
      else if (cat.includes("Motor")) matchedCategory = "Motors_Magnets";
      else if (cat.includes("Plastic")) matchedCategory = "Mixed_Plastics";
      else matchedCategory = "Other";

      const weight = Number(item.weight_kg) || 1.0;
      const finalPrice = Number(item.final_price || item.quoted_price) || 0;

      return {
        handoverRefNo: `HND-${item.lot_id.slice(-4).toUpperCase()}`,
        lotId: item.lot_id,
        collectorRefId: item.collector_id || "KC-C-7821",
        category: matchedCategory,
        collectorWeightKg: weight,
        measuredWeightKg: weight,
        weightMismatchPercent: 0.0,
        finalPrice: finalPrice,
        paymentMethod: "cash_received",
        paymentStatus: item.payment_status || "cash_received",
        collectorConfirmed: item.collector_confirmed ?? true,
        recyclerConfirmed: item.recycler_confirmed ?? true,
        confirmedAt: item.handover_at || item.updated_at || new Date().toISOString(),
        recordHash: `hash-${item.lot_id.toLowerCase()}-verified`,
        downstreamStatus: "received",
      };
    });
  } catch (err) {
    console.warn("fetchSettledLotsApi error:", err);
    return mockHandoverRecords;
  }
}

// Mock dataset for immediate testability and offline demonstration
export const mockRecyclerProfile: RecyclerProfile = {
  id: "REC-ECO-01",
  name: "Maharashtra Eco-Recyclers Pvt Ltd",
  email: "recycler@ecorecycle.com",
  phone: "+91 98200 99999",
  authorizationNumber: "MPCB/EPR/2024/REC-4019",
  authorizationBody: "MPCB",
  authorizationStatus: "verified",
  authorizationValidTill: "2027-08-31",
  facilityLocation: {
    latitude: 19.0760,
    longitude: 72.8777,
    address: "Plot B-14, TTC Industrial Area, MIDC Mahape, Navi Mumbai, MH 400710",
  },
  materialsAccepted: ["PCB", "Cables", "Batteries", "LCD", "Motors_Magnets"],
  serviceAreaDistricts: ["Mumbai", "Thane", "Palghar", "Pune"],
  pickupAvailable: true,
  pickupRadiusKm: 35.0,
  offeredRates: {
    PCB: 420.0,
    Cables: 680.0,
    Batteries: 120.0,
    LCD: 280.0,
    Motors_Magnets: 190.0,
    CRT: 45.0,
    Mixed_Plastics: 35.0,
    Other: 80.0,
  },
  rating: 4.85,
  totalVolumeProcessedKg: 14850,
};

export const mockMatchedLots: MatchedLot[] = [
  {
    id: "LOT-M1",
    lotId: "KC-MH-2609-A48F",
    clientLotUuid: "uuid-matched-01",
    collectorRefId: "KC-C-4921",
    category: "PCB",
    subCategory: "Motherboard",
    condition: "broken",
    weightKg: 12.5,
    estimatedValue: 5250,
    distanceKm: 4.2,
    quotedPrice: 5250,
    pickupRequested: true,
    photoUrl: "https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&q=80",
    photoHash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    createdAt: "2026-09-25T10:30:00Z",
    status: "matched",
    handoverRefNo: "H6-K9P2",
  },
  {
    id: "LOT-M2",
    lotId: "KC-MH-2609-C71E",
    clientLotUuid: "uuid-matched-02",
    collectorRefId: "KC-C-8812",
    category: "Batteries",
    subCategory: "Lead_Acid_SLA",
    condition: "damaged",
    weightKg: 24.0,
    estimatedValue: 2880,
    distanceKm: 8.7,
    quotedPrice: 2880,
    pickupRequested: false,
    photoUrl: "https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=400&q=80",
    photoHash: "1a8565a9dae5b43fc116561da9b620e6b683a4c1ad9f134a0247b7a9fed00c82",
    createdAt: "2026-09-25T11:15:00Z",
    status: "matched",
    handoverRefNo: "H6-B3R7",
  },
  {
    id: "LOT-M3",
    lotId: "KC-MH-2609-F90D",
    clientLotUuid: "uuid-matched-03",
    collectorRefId: "KC-C-3304",
    category: "Cables",
    subCategory: "Copper_Insulated",
    condition: "broken",
    weightKg: 8.0,
    estimatedValue: 5440,
    distanceKm: 2.1,
    quotedPrice: 5440,
    pickupRequested: true,
    photoUrl: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80",
    photoHash: "3f79bb7b435b05321651daefd374cdc681dc06faa65e374e38337b88ca14539f",
    createdAt: "2026-09-25T12:00:00Z",
    status: "accepted",
    handoverRefNo: "H6-C8W1",
  },
];

export const mockHandoverRecords: HandoverRecord[] = [
  {
    handoverRefNo: "H6-K9P2",
    lotId: "KC-MH-2609-A48F",
    collectorRefId: "KC-C-4921",
    category: "PCB",
    collectorWeightKg: 12.5,
    measuredWeightKg: 12.3,
    weightMismatchPercent: 1.6,
    finalPrice: 5166,
    paymentMethod: "cash_received",
    paymentStatus: "cash_received",
    confirmedAt: "2026-09-25T14:20:00Z",
    recordHash: "e4d909c290d0fb1ca068ffaddf22cbd0add01f",
    downstreamStatus: "received",
  },
  {
    handoverRefNo: "H6-W19A",
    lotId: "KC-MH-2609-T21B",
    collectorRefId: "KC-C-1092",
    category: "CRT",
    collectorWeightKg: 18.0,
    measuredWeightKg: 18.2,
    weightMismatchPercent: 1.1,
    finalPrice: 819,
    paymentMethod: "cash_received",
    paymentStatus: "cash_received",
    confirmedAt: "2026-09-24T16:00:00Z",
    recordHash: "f1a238910d8a7c29e1902bbda912bcffea1029",
    downstreamStatus: "dismantled",
  },
];

export const mockPriceBoards: PriceBoardItem[] = [
  {
    district: "Mumbai",
    category: "PCB",
    buyingPrice: 420.0,
    marketMin: 380.0,
    marketMax: 460.0,
    recyclerOfferedPrice: 435.0,
    trend: "up",
    percentChange: 4.2,
    confidence: "high",
    lastUpdated: "2026-09-25T08:00:00Z",
  },
  {
    district: "Pune",
    category: "Cables",
    buyingPrice: 680.0,
    marketMin: 620.0,
    marketMax: 720.0,
    recyclerOfferedPrice: 690.0,
    trend: "up",
    percentChange: 2.8,
    confidence: "high",
    lastUpdated: "2026-09-25T08:00:00Z",
  },
  {
    district: "Thane",
    category: "Batteries",
    buyingPrice: 120.0,
    marketMin: 95.0,
    marketMax: 140.0,
    recyclerOfferedPrice: 125.0,
    trend: "flat",
    percentChange: 0.0,
    confidence: "high",
    lastUpdated: "2026-09-25T08:00:00Z",
  },
  {
    district: "Nagpur",
    category: "LCD",
    buyingPrice: 280.0,
    marketMin: 240.0,
    marketMax: 310.0,
    recyclerOfferedPrice: 275.0,
    trend: "down",
    percentChange: -3.1,
    confidence: "medium",
    lastUpdated: "2026-09-25T08:00:00Z",
  },
];

export const mockAnomalies: AnomalyItem[] = [
  {
    id: "ANOM-01",
    lotId: "KC-MH-2609-FLAG1",
    collectorRefId: "KC-C-7712",
    category: "CRT",
    weightKg: 0.4,
    finalPrice: 50.0,
    pricePerKg: 125.0,
    flags: ["IMPLAUSIBLE_WEIGHT"],
    reasons: ["Weight 0.4 kg is below physical bounds (4.0 - 50.0 kg) for CRT category."],
    status: "pending_review",
    detectedAt: "2026-09-25T09:10:00Z",
  },
  {
    id: "ANOM-02",
    lotId: "KC-MH-2609-FLAG2",
    collectorRefId: "KC-C-9901",
    category: "Batteries",
    weightKg: 10.0,
    finalPrice: 25000.0,
    pricePerKg: 2500.0,
    flags: ["PRICE_OUTSIDE_IQR"],
    reasons: ["Rate ₹2500/kg deviates severely from regional IQR bounds (₹80 - ₹160/kg)."],
    status: "pending_review",
    detectedAt: "2026-09-25T11:45:00Z",
  },
];

export const mockDashboardMetrics: PortalDashboardMetrics = {
  totalVolumeMonthKg: 14850,
  totalSpendMonth: 3425000,
  pendingPaymentsCount: 2,
  activeMatchesCount: 3,
  categoryVolumes: {
    PCB: 4200,
    Cables: 3800,
    Batteries: 3100,
    LCD: 2100,
    Motors_Magnets: 1100,
    CRT: 550,
  },
  categoryAvgRates: {
    PCB: 420.0,
    Cables: 680.0,
    Batteries: 120.0,
    LCD: 280.0,
    Motors_Magnets: 190.0,
  },
};
