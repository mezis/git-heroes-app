This directory contains API response examples take directly from:
https://developer.github.com/v3/

The naming convention is: `<type>-<variant>`, where `<variant>` is:

- `long`, when the response is for a single-resource GET;
- `index`, a list of resources, possibly with a shorter representations.

In some cases, changes to the examples had to be made as they were semantically
incorrect.

- In `pull-request-*`, `status` was changed to `closed` (because `merged_at`,
etc are set).
