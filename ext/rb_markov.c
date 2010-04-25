#include "markov.h"
#include "ruby.h"
#include "rubyio.h"
#include "intern.h"

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
                
        markov_add_input_from_stream(data, GetReadFile(fptr));
    }
    else {
        rb_raise(rb_eException, "Unknown input type");
    }

    return self;
}

static VALUE mk_generate_to_stream(VALUE self, VALUE out) {
    MarkovData* data;
    Data_Get_Struct(self, MarkovData, data);
    
    if (TYPE(out) == T_FILE) {        
        rb_io_t* fptr;
        GetOpenFile(out, fptr);
        
        markov_generate_to_stream(data, GetWriteFile(fptr), 250);
    }
    else {
        rb_raise(rb_eException, "Unknown output type");
    }
    
    return Qnil;
}

static VALUE mk_generate_string(VALUE self) {
    MarkovData* data;
    Data_Get_Struct(self, MarkovData, data);
    
    char* c_string = markov_generate_to_string(data, 0);
    
    VALUE rb_str = rb_str_new2(c_string);
    free(c_string);
    
    return rb_str;
}

void Init_Markov() {
    VALUE mk_class = rb_define_class("Markov", rb_cObject);
    
    rb_define_alloc_func(mk_class, mk_alloc);
    rb_define_method(mk_class, "initialize", mk_initialize, 0);
    rb_define_method(mk_class, "add_input", mk_add_input, 1);
    rb_define_method(mk_class, "generate_to_stream", mk_generate_to_stream, 1);
    rb_define_method(mk_class, "generate_string", mk_generate_string, 0);
    
}