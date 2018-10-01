#!/usr/bin/env bash

echo '#!/usr/bin/env bash'>deployer
cat <./scripts/constant.sh | sed -E 's|#!/usr/bin/env bash||'>>deployer
cat <./scripts/utils.sh    | sed -E 's|#!/usr/bin/env bash||'>>deployer
cat <./scripts/commands.sh | sed -E 's|#!/usr/bin/env bash||'>>deployer
cat <./scripts/index.sh    | sed -E 's|#!/usr/bin/env bash||'>>deployer

chmod +x deployer
