// Include MicroPython API.
#include "py/runtime.h"
#include "py/mpprint.h"
#include "py/objstr.h"
#include "py/objarray.h"
#include "py/mpprint.h"
#include "py/qstr.h"
#include "py/misc.h"
#include "py/obj.h"

#include "tensorflow-microlite.h"

#include "openmv-libtf.h"

#include "tensorflow/lite/core/c/common.h"



// needs to be manually updated when the firmware is built.
// see if we can pass through the project git commit when this is run.

// The tensor object =================================================

static const mp_obj_type_t microlite_tensor_type;


static mp_obj_t tensor_get_value(mp_obj_t self_in, mp_obj_t index_obj) {

    // Get our tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    // Get the tflite tensor object from our tensor object
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // If the tensor is a float32, return a float
    if (tensor->type == kTfLiteFloat32) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);
        float f_value = tensor->data.f[index];
        return mp_obj_new_float_from_f(f_value);
    }

    // If the tensor is int8, return an mp int
    else if (tensor->type == kTfLiteInt8) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);
        int8_t int8_value = tensor->data.int8[index];
        return mp_obj_new_int(int8_value);
    }

    // If the tensor is uint8, return an mp int
    else if (tensor->type == kTfLiteUInt8) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);

        uint8_t int8_value = tensor->data.uint8[index];

        return mp_obj_new_int(int8_value);
    }
    // Otherwise, raise an error
    else {
        mp_raise_TypeError(MP_ERROR_TEXT("Unsupported Tensor Type"));
    }

    // Return none
    return mp_const_none;
}


static mp_obj_t tensor_set_value (mp_obj_t self_in, mp_obj_t index_obj, mp_obj_t value) {

    // Get the index from the index object
    mp_int_t index = mp_obj_int_get_checked(index_obj);

    // Get our tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // Set if float32 value
    if (tensor->type == kTfLiteFloat32) {
        tensor->data.f[index] = mp_obj_get_float_to_f(value);
    }
    // Set int8 value
    else if (tensor->type == kTfLiteInt8) {
        mp_int_t int_value = mp_obj_int_get_checked(value);
        int8_t int8_value = (int8_t)int_value;
        tensor->data.int8[index] = int8_value;
    }
    // Set the uint8 value
    else if (tensor->type == kTfLiteUInt8) {
        mp_int_t int_value = mp_obj_int_get_checked(value);
        uint8_t uint8_value = (uint8_t)int_value;
        tensor->data.uint8[index] = uint8_value;
    }
    // Otherwise, raise an error
    else {
        mp_raise_TypeError(MP_ERROR_TEXT("Unsupported Tensor Type"));
    }

    // Return our tensor object
    return MP_OBJ_FROM_PTR(self);
}


static mp_obj_t tensor_get_tensor_type(mp_obj_t self_in, mp_obj_t index_obj) {

    // Get our tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // Get the type of data in the tensor
    // TODO: Error Here
    const char *type = TfLiteTypeGetName(tensor->type);

    // Return the type as a string
    return mp_obj_new_str(type, strlen(type));

}


static mp_obj_t tensor_quantize_float_to_int8(mp_obj_t self_in, mp_obj_t float_obj) {

    // Check that the object received is a float
    if (!mp_obj_is_float(float_obj)) {
        // Raise an error
        mp_raise_TypeError(MP_ERROR_TEXT("Expecting Parameter of float type"));
    }

    // Get our tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // Check that the tensor is of type int8
    if (tensor->type != kTfLiteInt8) {
        mp_raise_TypeError ("Expected Tensor to be of type ktfLiteInt8.");
    }

    // Converts the object to a float
    // TODO: This won't work on boards without floating point support
    float value = mp_obj_get_float_to_f(float_obj);

    // Quantize the input from floating-point to integer
    int8_t quantized_value = (int8_t)(value / tensor->params.scale + tensor->params.zero_point);

    // Return the quantized value
    return MP_OBJ_NEW_SMALL_INT(quantized_value);
}


static mp_obj_t tensor_quantize_int8_to_float (mp_obj_t self_in, mp_obj_t int_obj) {

    // Check that the object received is an int
    if (!mp_obj_is_integer(int_obj)) {
        mp_raise_TypeError(MP_ERROR_TEXT("Expecting Parameter of float type"));
    }

    // Get our tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // Check that the tensor is of type int8
    if (tensor->type != kTfLiteInt8) {
        mp_raise_TypeError(MP_ERROR_TEXT("Expected Tensor to be of type ktfLiteInt8."));
    }

    // Get the int8 value from the object
    int8_t value = mp_obj_int_get_checked(int_obj);

    // Quantize the input from integer to float
    float quantized_value = (value - tensor->params.zero_point) * tensor->params.scale;

    // Return the float value
    return mp_obj_new_float_from_f(quantized_value);
}


MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_get_value, tensor_get_value);
MP_DEFINE_CONST_FUN_OBJ_3(microlite_tensor_set_value, tensor_set_value);
MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_get_tensor_type, tensor_get_tensor_type);
MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_quantize_float_to_int8, tensor_quantize_float_to_int8);
MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_quantize_int8_to_float, tensor_quantize_int8_to_float);


static void tensor_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    // Ignore the kind parameter
    (void)kind;

    // Get the tensor object
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);
    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    // The number of dimensions
    int size = tensor->dims->size;

    // The output will look like this: tensor(type=uint8, dims->size=4)
    mp_print_str(print, "tensor(type=");
    // TODO: Error Here
    mp_print_str(print, TfLiteTypeGetName(tensor->type));
    mp_printf(print, ", dims->size=%d\n", size);
    mp_print_str(print, ")\n");
}

// The functions that are available to the tensor object
// getValue - returns the value of the tensor
// setValue - sets the value of the tensor
// getType - returns the type of the tensor
// quantizeFloatToInt8 - quantizes a float tensor to an int8 tensor
// quantizeInt8ToFloat - quantizes an int8 tensor to a float tensor
static const mp_rom_map_elem_t tensor_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_getValue), MP_ROM_PTR(&microlite_tensor_get_value) },
    { MP_ROM_QSTR(MP_QSTR_setValue), MP_ROM_PTR(&microlite_tensor_set_value) },
    { MP_ROM_QSTR(MP_QSTR_getType), MP_ROM_PTR(&microlite_tensor_get_tensor_type) },
    { MP_ROM_QSTR(MP_QSTR_quantizeFloatToInt8), MP_ROM_PTR(&microlite_tensor_quantize_float_to_int8) },
    { MP_ROM_QSTR(MP_QSTR_quantizeInt8ToFloat), MP_ROM_PTR(&microlite_tensor_quantize_int8_to_float) }
};


static MP_DEFINE_CONST_DICT(tensor_locals_dict, tensor_locals_dict_table);


static MP_DEFINE_CONST_OBJ_TYPE(
        microlite_tensor_type,
        MP_QSTR_tensor,
        MP_TYPE_FLAG_NONE,
        print, tensor_print,
        locals_dict, (mp_obj_dict_t*)&tensor_locals_dict
);


// Interpreter Object ================================================

static const mp_obj_type_t microlite_interpreter_type;


static mp_obj_t interpreter_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    // Args:
    //  - model
    //  - size of the tensor arena
    //  - input callback function
    //  - output callback function
    mp_arg_check_num(n_args, n_kw, 4, 4, false);

    // Get the model bytes, this is a memoryview object
    mp_obj_array_t *model = MP_OBJ_TO_PTR (args[0]);

    // This is the size of the tensor arena we will use
    // The tensor arena is a memoryview object
    mp_obj_array_t *arena = MP_OBJ_TO_PTR (args[1]);

    // This is the function run before each inference
    mp_obj_t input_callback_fn = args[2];

    // This is the function run after each inference
    mp_obj_t output_callback_fn = args[3];

    // Make sure the input callback is a valid function
    if (input_callback_fn != mp_const_none && !mp_obj_is_callable(input_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Input Callback Handler"));
    }

    // Make sure the output callback is a valid function
    if (output_callback_fn != mp_const_none && !mp_obj_is_callable(output_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Output Callback Handler"));
    }

    // Create a new interpreter object
    microlite_interpreter_obj_t *self = m_new_obj(microlite_interpreter_obj_t);

    // Set the input and output callback functions
    self->input_callback = input_callback_fn;
    self->output_callback = output_callback_fn;

    // Set the inference count to zero
    self->inference_count = 0;

    // Set the type
    self->base.type = &microlite_interpreter_type;

    // Set the model data
    self->model_data = model;

    // Set the tensor arena
    self->tensor_arena = arena;

    mp_printf(MP_PYTHON_PRINTER, "interpreter_make_new: model size = %d, tensor arena = %d\n", self->model_data->len, self->tensor_arena->len);

    // Initialize the interpreter
    int code = libtf_interpreter_init(self);

    // If the interpreter failed to initialize, return None
    if (code != 0) {
        return mp_const_none;
    }

    // Return the interpreter object
    return MP_OBJ_FROM_PTR(self);
}


static mp_obj_t interpreter_invoke(mp_obj_t self_in) {

    // Get the interpreter object
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    // Invoke the interpreter
    int code = libtf_interpreter_invoke(self);

    // Increment the inference count
    self->inference_count += 1;

    // Return the status code
    return mp_obj_new_int(code);
}


static mp_obj_t interpreter_get_input_tensor(mp_obj_t self_in, mp_obj_t index_obj) {

    // Convert the index to an unsigned integer
    mp_uint_t index = mp_obj_int_get_uint_checked(index_obj);

    // Get the interpreter object
    microlite_interpreter_obj_t *microlite_interpreter = MP_OBJ_TO_PTR(self_in);

    // Create a new tensor object
    microlite_tensor_obj_t *microlite_tensor = m_new_obj(microlite_tensor_obj_t);

    // Get the input tensor at the given index
    TfLiteTensor *input_tensor = libtf_interpreter_get_input_tensor(microlite_interpreter, index);

    // Set the tensor object
    microlite_tensor->tf_tensor = input_tensor;
    microlite_tensor->microlite_interpreter = microlite_interpreter;

    // TODO: Put back microlite_tensor_type
    microlite_tensor->base.type = &microlite_tensor_type;

    // Return the tensor object
    return MP_OBJ_FROM_PTR(microlite_tensor);
}


static mp_obj_t interpreter_get_output_tensor(mp_obj_t self_in, mp_obj_t index_obj) {
    // Convert the index to an unsigned integer
    mp_uint_t index = mp_obj_int_get_uint_checked(index_obj);

    // Get the interpreter object
    microlite_interpreter_obj_t *microlite_interpreter = MP_OBJ_TO_PTR(self_in);

    // Create a new tensor object
    microlite_tensor_obj_t *microlite_tensor = m_new_obj(microlite_tensor_obj_t);

    // Get the output tensor at the given index
    TfLiteTensor *output_tensor = libtf_interpreter_get_output_tensor(microlite_interpreter, index);

    // Set the tensor object
    microlite_tensor->tf_tensor = output_tensor;
    microlite_tensor->microlite_interpreter = microlite_interpreter;

    // TODO: Put back microlite_tensor_type
    microlite_tensor->base.type = &microlite_tensor_type;

    // Return the tensor object
    return MP_OBJ_FROM_PTR(microlite_tensor);
}


MP_DEFINE_CONST_FUN_OBJ_1(microlite_interpreter_invoke, interpreter_invoke);
MP_DEFINE_CONST_FUN_OBJ_2(microlite_interpreter_get_input_tensor, interpreter_get_input_tensor);
MP_DEFINE_CONST_FUN_OBJ_2(microlite_interpreter_get_output_tensor, interpreter_get_output_tensor);


static void interpreter_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    // Ignore the kind parameter
    (void)kind;

    // Get the interpreter object
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    // Get the output tensor
    // TODO: 'interpreter_get_input_tensor'; did you mean 'libtf_interpreter_get_input_tensor'?
    microlite_tensor_obj_t *output_tensor = MP_OBJ_TO_PTR(interpreter_get_input_tensor(self, 0));

    // The output will be like this: interpreter(model size = 1234, tensor_arena size = 1234)
    mp_print_str(print, "interpreter(");
    mp_printf(print, "model size = %d, tensor_arena size = %d\n", self->model_data->len, self->tensor_arena->len);
    mp_obj_print_helper(print, output_tensor, PRINT_STR);
    mp_print_str(print, ")");
}


// The functions that are available to the interpreter object
// Invoke - Invokes the interpreter
// getInputTensor - Returns the input tensor
// getOutputTensor - Returns the output tensor
static const mp_rom_map_elem_t interpreter_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_invoke), MP_ROM_PTR(&microlite_interpreter_invoke) },
    { MP_ROM_QSTR(MP_QSTR_getInputTensor), MP_ROM_PTR(&microlite_interpreter_get_input_tensor) },
    { MP_ROM_QSTR(MP_QSTR_getOutputTensor), MP_ROM_PTR(&microlite_interpreter_get_output_tensor) },
};


static MP_DEFINE_CONST_DICT(interpreter_locals_dict, interpreter_locals_dict_table);


static MP_DEFINE_CONST_OBJ_TYPE(
        microlite_interpreter_type,
        MP_QSTR_interpreter,
        MP_TYPE_FLAG_NONE,
        make_new, interpreter_make_new,
        print, interpreter_print,
        locals_dict, (mp_obj_dict_t*)&interpreter_locals_dict
);

// ====================================================================


// The microlite __version__ string
static const MP_DEFINE_STR_OBJ(microlite_version_string_obj, TFLITE_MICRO_VERSION);


static const mp_rom_map_elem_t microlite_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_microlite) },
    { MP_ROM_QSTR(MP_QSTR___version__), MP_ROM_PTR(&microlite_version_string_obj) },

    { MP_ROM_QSTR(MP_QSTR_tensor), (mp_obj_t)&microlite_tensor_type },
    { MP_ROM_QSTR(MP_QSTR_interpreter), (mp_obj_t)&microlite_interpreter_type },
};


static MP_DEFINE_CONST_DICT(microlite_module_globals, microlite_module_globals_table);


// Module Object ================================================
const mp_obj_module_t microlite_cmodule = {
        .base = { &mp_type_module },
        .globals = (mp_obj_dict_t *)&microlite_module_globals,
};

MP_REGISTER_MODULE(MP_QSTR_microlite, microlite_cmodule);
