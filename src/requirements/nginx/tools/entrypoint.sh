#!/bin/bash

set -e

/generate-certificate.sh

exec nginx -g "daemon off;"
