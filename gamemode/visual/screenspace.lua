function GM:RenderScreenspaceEffects()
	DrawBloom(
        0.65, -- Darken
        0.9, -- Multiply
        5, -- S_X
        5, -- S_Y
        1, -- Passes
        1, -- ColorMultiply
        1, -- R
        0.8, -- G
        0.8 -- B
    )
end 