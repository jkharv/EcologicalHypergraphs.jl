SpeciesInteractionNetworks.species(fwm::FoodwebModel) = species(fwm.hg)
SpeciesInteractionNetworks.richness(fwm::FoodwebModel) = richness(fwm.hg) 
SpeciesInteractionNetworks.interactions(fwm::FoodwebModel) = interactions(fwm.hg) 

function set_initial_condition!(fwm::FoodwebModel{T}, u0::Dict{T, Float64}) where T

    for k ∈ keys(u0)

        if k ∈ species(fwm) 
            b = fwm.vars[k]
        else
            b = fwm.aux_vars[k]
        end

        fwm.u0[b] = u0[k]
    end
end

function isproducer(fwm::FoodwebModel, sp)::Bool

    @assert sp ∈ species(fwm)

    for intx ∈ interactions(fwm)

        if isloop(intx)

            continue
        elseif subject(intx) == sp

            return false
        end
    end

    return true
end

function isconsumer(fwm::FoodwebModel, sp)::Bool

    return !isproducer(fwm, sp)
end