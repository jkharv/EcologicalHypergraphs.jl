# function create_runtime_replacement_symbols(tmplt, spp, fwm)

#     for o ∈ tmplt.objects

#     end
# end

function create_runtime_symbol(x::TemplateVectorVariable, spp, fwm)

    return [fwm.vars[x] for x ∈ spp]
end

function create_runtime_symbol(x::TemplateScalarVariable, spp, fwm)

    if length(unique(spp)) ≠ 1
        
        error(
        """
        You're using scalar variable syntax but this group has multiple \
        species in it. Did you mean to use:
        
        `x[] -> f(x[begin:end])`
        """)
    end

    return fwm.vars[spp[1]]
end

function create_runtime_symbol(tmplt::TemplateScalarParameter, spp, fwm)

    # Make it unambigous
    sym = (gensym ∘ join)([tmplt.sym, spp...], "_" )

    # Create the parameter and add it to the FoodwebModel.
    param = create_param(sym)
    push!(fwm.params, param)
    push!(fwm.param_vals, param => tmplt.val)

    return param
end

function create_runtime_symbol(tmplt::TemplateVectorParameter, spp, fwm)

    # Make it unambigous
    sym = join([tmplt.sym, spp...], "_" )
    syms = [join([sym, i], "_") for i ∈ 1:length(spp)]
    syms = (gensym ∘ Symbol).(syms)

    # Create the parameter and add it to the FoodwebModel.
    params = create_param.(syms)
    append!(fwm.params, params)
    vals = [tmplt.val for i ∈ 1:length(spp)]
    merge!(fwm.param_vals, Dict(params .=> vals))

    return params
end

# TODO Make these not try and re-replace the symbols that have already been
# substituded into the template at each run. Pro add a vector of flags to the 
# FunctionalTemplate object to keep track of which have already been done.  It
# used to keep track of this by just deleting the entry in the RenameDict but it
# turns out I needed to keep the information later to create the DynamicalRule 
# object.

function apply_template(tmplt::FunctionTemplate, obj::TemplateObject)   
  
    sym = obj.sym
    var = tmplt.objects[obj]

    ff = postwalk(x -> x == sym ? var : x, tmplt.forwards_function)
    bf = postwalk(x -> x == sym ? var : x, tmplt.backwards_function)

    fn = FunctionTemplate(ff, bf, copy(tmplt.canonical_vars), copy(tmplt.objects))

    return fn
end

function apply_template(tmplt::FunctionTemplate)

    for o ∈ tmplt.objects

        if !ismissing(last(o))

            tmplt = apply_template(tmplt, first(o))
        end
    end
    return tmplt
end