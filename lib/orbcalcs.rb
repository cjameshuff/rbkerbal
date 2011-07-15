
G = 6.67300e-11
M_KERBAL = 5.29e22 # kg

def eccentricity(per, ap)
    (1 - 2.0/(ap/per + 1))
end

def tcirc(r, m)
    2*Math::PI*Math.sqrt(r**3/(G*m))
end

def vcirc(r, m)
    Math.sqrt(G*m/r)
end

def tell(r, per, ap, m)
    2*Math::PI*Math.sqrt(((per + ap)/2.0)**3/(G*m))
end

def vell(r, per, ap, m)
    Math.sqrt(G*m*(2/r - 2/(per + ap)))
end

def vesc(r, m)
    Math.sqrt(2*G*m/r)
end

def semimaj(r, v, m)
    1.0/(2.0/r - v*v/(G*m))
end

def opoapsis(r, v, m)
    2.0*semimaj(r, v, m) - r
end

# Specific energy (E/m)
def espec(r, v, m)
    ((v*v)/2.0 - (G*m)/r)
end

def vexcess(r, v, m)
    Math.sqrt(2.0*espec(r, v, m))
end

def calcmass(r, v, per, ap)
    v*v/G/(2.0/(600.0e3 + r) - 2.0/(1200.0e3 + per + ap))
end
