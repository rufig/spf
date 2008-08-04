REQUIRE EMBODY ~pinka/spf/forthml/index.f

REQUIRE STHROW          ~pinka/spf/sthrow.f
REQUIRE DLOPEN          ~ac/lib/ns/dlopen.f


REQUIRE CREATED-DLPOINT ~pinka/spf/ffi/core.f

`~pinka/spf/ffi/spf4-ffi-sugar.f.xml FIND-FULLNAME2  EMBODY

1024 50 * INIT-FFI-STORAGE \ (!!!)
