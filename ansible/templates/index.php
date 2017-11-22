<?php
 echo "Hello World. Sistema operativo" . {{ ansible_distribution }} . "  " . {{ ansible_distribution_major_version}};