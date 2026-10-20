package avmsec

import rego.v1

# The zipdeploy ARM API must fetch the example package from this public HTTPS URL.
exception contains rules if {
    rules = ["AVM_SEC_STORAGE_PE_PUBLIC_ACCESS"]
}
