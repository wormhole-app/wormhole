#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_send_file(int64_t port_,
                    struct wire_uint_8_list *file_name,
                    struct wire_uint_8_list *file_path,
                    uint8_t code_length);

void wire_request_file(int64_t port_,
                       struct wire_uint_8_list *passphrase,
                       struct wire_uint_8_list *storage_folder);

void wire_get_passphrase_uri(int64_t port_,
                             struct wire_uint_8_list *passphrase,
                             struct wire_uint_8_list *rendezvous_server);

void wire_new__static_method__TUpdate(int64_t port_, int32_t event, struct wire_uint_8_list *value);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_send_file);
    dummy_var ^= ((int64_t) (void*) wire_request_file);
    dummy_var ^= ((int64_t) (void*) wire_get_passphrase_uri);
    dummy_var ^= ((int64_t) (void*) wire_new__static_method__TUpdate);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}