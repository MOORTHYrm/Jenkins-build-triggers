#!/bin/bash
echo "Build started at $(date)"
echo "Remote URL: $(git config --get remote.origin.url)"
echo "Latest commit: $(git log -1 --oneline)"
case "$(git config --get remote.origin.url)" in
  git@*) echo "Checkout used SSH key: OK" ;;
  *)     echo "Checkout did NOT use SSH"; exit 1 ;;
esac
