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

# Milbendruck-Schwellen (ADR-0004). Anzahl erreichter Schwellen = Druck 0..3.
const VARROA_THRESHOLDS: Array[int] = [8, 14, 20]

# Bedrohungs-Phasenlaenge in Zuegen (ADR-0004).
const THREAT_PHASE_LENGTH: int = 3


## Milbendruck: Anzahl erreichter/ueberschrittener Varroa-Schwellen.
static func varroa_pressure(varroa: int) -> int:
	var pressure := 0
	for threshold: int in VARROA_THRESHOLDS:
		if varroa >= threshold:
			pressure += 1
	return pressure
