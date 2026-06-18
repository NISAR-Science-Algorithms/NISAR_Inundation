from datetime import datetime
from pathlib import PurePosixPath
import re
from urllib.parse import urlparse

NISAR_TS_RE = re.compile(r"_(\d{8}T\d{6})_")

def nisar_start_time_from_url(s3_url: str) -> datetime:
    path = urlparse(s3_url).path
    name = PurePosixPath(path).name
    
    m = NISAR_TS_RE.search(name)
    if not m:
        raise ValueError(f"No NISAR timestamp found in: {s3_url}")
    
    return datetime.strptime(m.group(1), "%Y%m%dT%H%M%S")
