local motifs = {}

-- motifs implemented for now:
--------------------------
-- right
-- right A
-- right B
-- right A B
-- left
-- left A
-- left B
-- left A B

local motifKeys = {"right", "rightA", "rightB", "rightAB", "left", "leftA", "leftB", "leftAB"}

local frameDurations = {10, 20, 25, 30}


motifs["right"] = {
    up = false,
    down = false,
    left = false,
    right = true,
    A = false,
    B = false
}

motifs["rightA"] = {
    up = false,
    down = false,
    left = false,
    right = true,
    A = true,
    B = false
}

motifs["rightB"] = {
    up = false,
    down = false,
    left = false,
    right = true,
    A = false,
    B = true
}

motifs["rightAB"] = {
    up = false,
    down = false,
    left = false,
    right = true,
    A = true,
    B = true
}

motifs["left"] = {
    up = false,
    down = false,
    left = true,
    right = false,
    A = false,
    B = false
}

motifs["leftA"] = {
    up = false,
    down = false,
    left = true,
    right = false,
    A = true,
    B = false
}

motifs["leftB"] = {
    up = false,
    down = false,
    left = true,
    right = false,
    A = false,
    B = true
}

motifs["leftAB"] = {
    up = false,
    down = false,
    left = true,
    right = false,
    A = true,
    B = true
}

return {
    motifs = motifs,
    motifKeys = motifKeys,
    frameDurations = frameDurations
}

