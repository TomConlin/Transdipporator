#! /usr/bin/env python3

import sys
import json
import yaml


def yaml2json(filename):
    structure = []
    with open(filename, 'r') as yamlfile:
        structure = yaml.load(yamlfile)
    sys.stdout.write(json.dumps(structure))


if __name__ == '__main__':
    filename = 0  # stdin
    if len(sys.argv) <= 2:
        filename = sys.argv[1]
    yaml2json(filename)
