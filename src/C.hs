module C where

import A (A)
import Cls

data C = C A

instance Cls C
