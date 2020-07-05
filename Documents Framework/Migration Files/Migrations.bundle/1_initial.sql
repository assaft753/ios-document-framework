CREATE TABLE document (
document_id INTEGER NOT NULL,
document_name TEXT NOT NULL,
is_closed INTEGER NOT NULL DEFAULT 0,
is_reported INTEGER NOT NULL DEFAULT 0,
skip INTEGER NOT NULL DEFAULT 0,
drafted INTEGER NOT NULL DEFAULT 0,
remote_url TEXT,
local_url TEXT,
created_date INTEGER,
is_downloaded INTEGER NOT NULL DEFAULT 0,
document_type TEXT NOT NULL,
seed INTEGER NOT NULL DEFAULT 0,
metadatas TEXT NOT NULL DEFAULT '[]',
user_id INTEGER,
barcodes TEXT NOT NULL DEFAULT '[]',
PRIMARY KEY(document_id)
);

CREATE TABLE log (
log_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
severity TEXT NOT NULL,
created_date INTEGER NOT NULL,
message TEXT NOT NULL
);

CREATE TABLE location (
location_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
created_date INTEGER NOT NULL,
longitude REAL NOT NULL,
latitude REAL NOT NULL
);

CREATE TABLE task (
task_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
notification_id TEXT,
type TEXT NOT NULL,
identifier INTEGER,
data TEXT
);
