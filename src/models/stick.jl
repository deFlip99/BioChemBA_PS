function prepare_stick_model(
        ac::AbstractAtomContainer{T};
        stick_radius=T(0.2),
        acID::Int=0) where {T<:Real}

    prepare_ball_and_stick_model(ac; sphere_radius=stick_radius, stick_radius=stick_radius, acID)
end
