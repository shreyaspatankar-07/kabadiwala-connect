export type UserRole = "recycler" | "admin" | "collector";

export interface UserSession {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  token?: string;
  recyclerId?: string;
  authorizationNumber?: string;
  isVerified?: boolean;
}

export type EwasteCategory =
  | "PCB"
  | "Cables"
  | "Batteries"
  | "CRT"
  | "LCD"
  | "Motors_Magnets"
  | "Mixed_Plastics"
  | "Other";

export interface RecyclerProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  authorizationNumber: string;
  authorizationBody: string; // CPCB | SPCB
  authorizationStatus: "verified" | "pending" | "expired" | "suspended" | "rejected";
  authorizationValidTill: string;
  facilityLocation: { latitude: number; longitude: number; address: string };
  materialsAccepted: EwasteCategory[];
  serviceAreaDistricts: string[];
  pickupAvailable: boolean;
  pickupRadiusKm: number;
  offeredRates: Record<EwasteCategory, number>;
  rating: number;
  totalVolumeProcessedKg?: number;
}

export interface MatchedLot {
  id: string;
  lotId: string;
  clientLotUuid: string;
  collectorRefId: string;
  category: EwasteCategory;
  subCategory?: string;
  condition: "working" | "broken" | "damaged" | "burnt";
  weightKg: number;
  estimatedValue: number;
  distanceKm: number;
  quotedPrice: number;
  pickupRequested: boolean;
  photoUrl: string;
  photoHash: string;
  createdAt: string;
  status: "matched" | "accepted" | "counter_offered" | "declined" | "handover_pending" | "handed_over";
  counterOfferRate?: number;
  handoverRefNo?: string;
  collectorConfirmed?: boolean;
  recyclerConfirmed?: boolean;
}

export interface HandoverRecord {
  handoverRefNo: string;
  lotId: string;
  collectorRefId: string;
  category: EwasteCategory;
  collectorWeightKg: number;
  measuredWeightKg: number;
  weightMismatchPercent: number;
  finalPrice: number;
  paymentMethod: "cash_received" | "digital_paid";
  paymentStatus: "cash_received" | "pending" | "digital_paid" | "disputed";
  collectorConfirmed?: boolean;
  recyclerConfirmed?: boolean;
  confirmedAt: string;
  recordHash: string;
  downstreamStatus: "received" | "dismantled" | "processed" | "certificate_issued";
}

export interface PriceBoardItem {
  district: string;
  category: EwasteCategory;
  buyingPrice: number;
  marketMin: number;
  marketMax: number;
  recyclerOfferedPrice: number;
  trend: "up" | "down" | "flat";
  percentChange: number;
  confidence: "high" | "medium" | "low";
  lastUpdated: string;
  isOverridden?: boolean;
}

export interface AnomalyItem {
  id: string;
  lotId: string;
  collectorRefId: string;
  category: EwasteCategory;
  weightKg: number;
  finalPrice: number;
  pricePerKg: number;
  flags: string[];
  reasons: string[];
  status: "pending_review" | "resolved" | "escalated";
  detectedAt: string;
}

export interface PortalDashboardMetrics {
  totalVolumeMonthKg: number;
  totalSpendMonth: number;
  pendingPaymentsCount: number;
  activeMatchesCount: number;
  categoryVolumes: Record<string, number>;
  categoryAvgRates: Record<string, number>;
}
