Utils = {}

function Utils.degtorad(deg)
  return deg * math.pi / 180
end

function Utils.radtodeg(rad)
  return rad * 180 / math.pi
end

function Utils.lerp(a, b, t)
  return a + (b - a) * t
end