class_name SaveService
extends RefCounted
## Atomares lokales Speichern (Block 2 / Blueprint AP 3.3): Temp-Datei schreiben,
## dann per Rename einsetzen — ein App-Kill mitten im Schreiben laesst die alte
## Datei intakt. `schemaVersion` gehoert in die gespeicherten Daten (Aufrufer).
## Kein Backend, keine personenbezogenen Daten.


static func save(path: String, data: Dictionary) -> bool:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("SaveService: kann Temp-Datei nicht schreiben: " + tmp)
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	var err := DirAccess.rename_absolute(tmp, path)
	if err != OK:
		push_error("SaveService: Rename fehlgeschlagen (%d)" % err)
		return false
	return true


static func load_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	return data if typeof(data) == TYPE_DICTIONARY else {}


static func exists(path: String) -> bool:
	return FileAccess.file_exists(path)
