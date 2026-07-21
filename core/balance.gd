class_name Balance
extends RefCounted
## Provisorische Balance-Konstanten (ADR-0003).
##
## UNSICHER — Startwerte, keine balancierten Zahlen. Werden in Phase 4
## (Balancing-Bot) und Phase 8 (Beta) empirisch gesetzt. Bewusst hier
## zentralisiert, damit sie ohne Logikaenderung wandern koennen.

const HAND_SIZE: int = 5
const START_MAX_ENERGY: int = 3
const START_STRENGTH: int = 40
const START_STORES: int = 0
const START_VARROA: int = 3

const VARROA_BASE_GROWTH: int = 1
const VARROA_GROWTH_PCT: int = 15
