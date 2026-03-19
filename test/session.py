import os
from pydantic_yaml import to_yaml_str

from ucl_open.core.experiment import Experiment


session = Experiment(
    workflow="main.bonsai",
    commit="",
    repository_url="https://github.com/ucl-open/rigs",
)


def main(output_dir):
    os.makedirs(output_dir, exist_ok=True)
    path = os.path.join(output_dir, f"{session.__class__.__name__}.yml")
    with open(path, "w", encoding="utf-8") as f:
        f.write(to_yaml_str(session))


if __name__ == "__main__":
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "local")
    main(output_dir)
