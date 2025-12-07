!!! warning "Error Handling"

All infra-bootstrap components use strict error handling:

```
- `set -e` ensures the script stops on any failure  
- `set -o pipefail` propagates failures inside pipelines  
- A `trap` handler prints the failing line number for debugging  

This prevents partial installations and ensures a **predictable, clean state** regardless of the failure point.
```
