import logging
import os
from pathlib import Path
from ucl_open.rigs.base import BaseSchema
from ucl_open.rigs.data_types import DataTypes
from ucl_open.rigs.displays import Displays
from typing import Type
from dataclasses import dataclass
import json

SCHEMA_ROOT = Path("./src/ucl_open/schemas")

@dataclass
class ToGenerateJsonSchema:
    model_name: str
    model: Type[BaseSchema]

def main():
    models = [
        ToGenerateJsonSchema(model_name="data_types", model=DataTypes),
        ToGenerateJsonSchema(model_name="displays_data_types", model=Displays)
    ]
    
    for model in models:
        schema = model.model.model_json_schema(union_format="primitive_type_array")
        schema.pop("properties", None)
        Path(f"{SCHEMA_ROOT}/{model.model_name}.json").write_text(json.dumps(schema, indent=2))
    
    
if __name__ == "__main__":
    main()