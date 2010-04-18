#include "markov.h"
#include "ruby.h"
#include "rubyio.h"

static void mk_free(void* data) {
    markov_free(data);
}

static VALUE mk_alloc(VALUE klass) {
    MarkovData* data = markov_init();
    
    VALUE obj = Data_Wrap_Struct(klass, 0, mk_free, data);
    
    return obj;
}

static VALUE mk_initialize(VALUE self) { //TODO: add options
    return self;
}

static VALUE mk_add_input(VALUE self, VALUE in) {
    MarkovData* data;
    Data_Get_Struct(self, MarkovData, data);
    
    if (TYPE(in) == T_FILE) {
        // FILE* file = GetReadFile(RFILE(in)->fptr);
        rb_io_t* fptr;
        GetOpenFile(in, fptr);
        
        markov_add_input(data, GetReadFile(fptr));
    }
    else {
        rb_raise(rb_eException, "Unknown input type");
    }

    return self;
}

static VALUE mk_generate(VALUE self, VALUE out) {
    MarkovData* data;
    Data_Get_Struct(self, MarkovData, data);
    
    if (TYPE(out) == T_FILE) {        
        rb_io_t* fptr;
        GetOpenFile(out, fptr);
        
        markov_generate(data, GetWriteFile(fptr), 250);
    }
    else {
        rb_raise(rb_eException, "Unknown output type");
    }
}

void Init_Markov() {
    VALUE mk_class = rb_define_class("Markov", rb_cObject);
    
    rb_define_alloc_func(mk_class, mk_alloc);
    rb_define_method(mk_class, "initialize", mk_initialize, 0);
    rb_define_method(mk_class, "add_input", mk_add_input, 1);
    rb_define_method(mk_class, "generate", mk_generate, 1);
}