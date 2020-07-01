local FixedQuaternion = {}

FixedQuaternion.New = function(x, y, z, w)
    local t = {
        x = x:Clone(),
        y = y:Clone(),
        z = z:Clone(),
        w = w:Clone(),
    }
    setmetatable(t, FixedQuaternion)
    return t
end

FixedQuaternion.Clone = function(a)
    return FixedQuaternion.New(a.x, a.y, a.z, a.w)
end

FixedQuaternion.Copy = function(a, b)
    a.x:Copy(b.x)
    a.y:Copy(b.y)
    a.z:Copy(b.z)
    a.w:Copy(b.w)
end

FixedQuaternion.Get = function(a)
    return a.x, a.y, a.z, a.w
end

FixedQuaternion.SetEuler = function(a, x, y, z)
    x = FixedMath.Deg2Rad(x) / FixedNumber.TWO
    y = FixedMath.Deg2Rad(y) / FixedNumber.TWO
    z = FixedMath.Deg2Rad(z) / FixedNumber.TWO
    local sinX = FixedMath.Sin(x)
    local cosX = FixedMath.Cos(x)
    local sinY = FixedMath.Sin(y)
    local cosY = FixedMath.Cos(y)
    local sinZ = FixedMath.Sin(z)
    local cosZ = FixedMath.Cos(z)
    a.w = cosY * cosX * cosZ + sinY * sinX * sinZ
    a.x = cosY * sinX * cosZ + sinY * cosX * sinZ
    a.y = sinY * cosX * cosZ - cosY * sinX * sinZ
    a.z = cosY * cosX * sinZ - sinY * sinX * cosZ
    return a
end

FixedQuaternion.Normalize = function(a)
    return a:Clone():SetNormalize()
end

FixedQuaternion.SetNormalize = function(a)
    local n = FixedMath.Sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
    if n > FixedNumber.ZERO then
        a.x = a.x / n
        a.y = a.y / n
        a.z = a.z / n
        a.w = a.w / n
    end
    return a
end

FixedQuaternion.SetFromToRotation1 = function(a, from, to)
    local v0 = from:Normalize()
    local v1 = to:Normalize()
    local d = FixedVector3.Dot(v0, v1)
    if d > FixedNumber.NEG_ONE then
        local s = FixedMath.Sqrt((FixedNumber.ONE + d) * FixedNumber.TWO)
        local invs = FixedNumber.ONE / s
        local c = FixedVector3.Cross(v0, v1) * invs
        a:Set(c.x, c.y, c.z, s / FixedNumber.TWO)
    elseif d >= FixedNumber.ONE then
        a:Set(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    else
        local axis = FixedVector3.Cross(FixedVector3.RIGHT, v0)
        if axis:SqrMagnitude() <= FixedNumber.ZERO then
            axis = FixedVector3.Cross(FixedVector3.FORWARD, v0)
        end
        a:Set(axis.x, axis.y, axis.z, FixedNumber.ZERO)
    end
    return a
end

local function MatrixToQuaternion(rot, quat)
    local trace = rot[1][1] + rot[2][2] + rot[3][3]
    if trace > FixedNumber.ZERO then
        local s = FixedMath.Sqrt(trace + FixedNumber.ONE)
        quat.w = s / FixedNumber.TWO
        s = FixedNumber.ONE / (FixedNumber.TWO * s)
        quat.x = (rot[3][2] - rot[2][3]) * s
        quat.y = (rot[1][3] - rot[3][1]) * s
        quat.z = (rot[2][1] - rot[1][2]) * s
        quat:SetNormalize()
    else
        local i = 1
        local q = {FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO}
        if rot[2][2] > rot[1][1] then
            i = 2
        end
        if rot[3][3] > rot[i][i] then
            i = 3
        end
        local NEXT = {2, 3, 1}
        local j = NEXT[i]
        local k = NEXT[j]
        local t = rot[i][i] - rot[j][j] - rot[k][k] + FixedNumber.ONE
        local s = FixedNumber.ONE / (FixedNumber.TWO * FixedMath.Sqrt(t))
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s
        quat:Set(q[1], q[2], q[3], w)
        quat:SetNormalize()
    end
end

FixedQuaternion.SetFromToRotation = function(a, from, to)
    from = from:Normalize()
    to = to:Normalize()
    local e = FixedVector3.Dot(from, to)
    if e >= FixedNumber.ONE then
        a:Set(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    elseif e <= FixedNumber.NEG_ONE then
        local left = {FixedNumber.ZERO, from.z, from.y}
        local mag = left[2] * left[2] + left[3] * left[3]
        if mag <= FixedNumber.ZERO then
            left[1] = -from.z
            left[2] = FixedNumber.ZERO
            left[3] = from.x
            mag = left[1] * left[1] + left[3] * left[3]
        end
        local invlen = FixedNumber.ONE / FixedMath.Sqrt(mag)
        left[1] = left[1] * invlen
        left[2] = left[2] * invlen
        left[3] = left[3] * invlen
        local up = {FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO}
        up[1] = left[2] * from.z - left[3] * from.y
        up[2] = left[3] * from.x - left[1] * from.z
        up[3] = left[1] * from.y - left[2] * from.x

        local fxx = -from.x * from.x
        local fyy = -from.y * from.y
        local fzz = -from.z * from.z
        local fxy = -from.x * from.y
        local fxz = -from.x * from.z
        local fyz = -from.y * from.z

        local uxx = up[1] * up[1]
        local uyy = up[2] * up[2]
        local uzz = up[3] * up[3]
        local uxy = up[1] * up[2]
        local uxz = up[1] * up[3]
        local uyz = up[2] * up[3]

        local lxx = -left[1] * left[1]
        local lyy = -left[2] * left[2]
        local lzz = -left[3] * left[3]
        local lxy = -left[1] * left[2]
        local lxz = -left[1] * left[3]
        local lyz = -left[2] * left[3]

        local rot = {
            {fxx + uxx + lxx, fxy + uxy + lxy, fxz + uxz + lxz},
            {fxy + uxy + lxy, fyy + uyy + lyy, fyy + uyy + lyy},
            {fxz + uxz + lxz, fyz + uyz + lyz, fzz + uzz + lzz},
        }
        MatrixToQuaternion(rot, a)
    else
        local v = FixedVector3.Cross(from, to)
        local h = (FixedNumber.ONE - e) / FixedVector3.Dot(v, v)
        local hx = h * v.x
        local hz = h * v.z
        local hxy = hx * v.y
        local hxz = hx * v.z
        local hyz = hz * v.y

        local rot = {
            {e + hx * v.x, hxy - v.z, hxz + v.y},
            {hxy + v.z, e + h * v.y * v.y, hyz - v.x},
            {hxz - v.y, hyz + v.x, e + hz * v.z},
        }
        MatrixToQuaternion(rot, a)
    end
    return a
end

FixedQuaternion.Inverse = function(a)
    return FixedQuaternion.New(-a.x, -a.y, -a.z, a.w)
end

FixedQuaternion.SetIndentity = function(a)
    a.x = FixedNumber.ZERO
    a.y = FixedNumber.ZERO
    a.z = FixedNumber.ZERO
    a.w = FixedNumber.ONE
    return a
end

FixedQuaternion.ToAngleAxis = function(a)
    local angle = FixedNumber.TWO * FixedMath.Acos(a.w)
    if angle == FixedNumber.ZERO then
        return FixedMath.Rad2Deg(angle), FixedVector3.New(FixedNumber.ONE, FixedNumber.ZERO, FixedNumber.ZERO)
    end
    local div = FixedNumber.ONE / FixedMath.Sqrt(FixedNumber.ONE - FixedMath.Sqrt(a.w))
    return FixedMath.Rad2Deg(angle), FixedVector3.New(a.x * div, a.y * div, a.z * div)
end

local NEG_FLIP = -FixedNumber.DOT0001
local POS_FLIP = FixedMath.TWO_PI - FixedNumber.DOT0001

local function SanitizeEuler(euler)
    if euler.x < NEG_FLIP then
        euler.x = euler.x + FixedNumber.TWO_PI
    elseif euler.x > POS_FLIP then
        euler.x = euler.x - FixedNumber.TWO_PI
    end
    if euler.y < NEG_FLIP then
        euler.y = euler.y + FixedNumber.TWO_PI
    elseif euler.y > POS_FLIP then
        euler.y = euler.y - FixedNumber.TWO_PI
    end
    if euler.z < NEG_FLIP then
        euler.z = euler.z + FixedNumber.TWO_PI
    elseif euler.z > POS_FLIP then
        euler.z = euler.z + FixedNumber.TWO_PI
    end
end

FixedQuaternion.ToEulerAngles = function(a)
    local x = a.x
    local y = a.y
    local z = a.z
    local w = a.w
    local check = FixedNumber.TWO * (y * z - w * x)
    if check < FixedNumber.ONE + NEG_FLIP then
        if check > FixedNumber.NEG_ONE - NEG_FLIP then
            local v = FixedVector3.New(-FixedMath.Asin(check)
                , FixedMath.Atan2(FixedNumber.TWO * (x * z + w * y), FixedNumber.ONE - FixedNumber.TWO * (x * x + y * y))
                , FixedMath.Atan2(FixedNumber.TWO * (x * y + w * z), FixedNumber.ONE - FixedNumber.TWO * (x * x + z * z)))
            SanitizeEuler(v)
            v.x = FixedMath.Rad2Deg(v.x)
            v.y = FixedMath.Rad2Deg(v.y)
            v.z = FixedMath.Rad2Deg(v.z)
            return v
        else
            local v = FixedVector3.New(FixedMath.HALF_PI
                , FixedMath.Atan2(FixedNumber.TWO * (x * y - w * z), FixedNumber.ONE - FixedNumber.TWO * (y * y + z * z))
                , FixedNumber.ZERO)
            SanitizeEuler(v)
            v.x = FixedMath.Rad2Deg(v.x)
            v.y = FixedMath.Rad2Deg(v.y)
            v.z = FixedMath.Rad2Deg(v.z)
            return v
        end
    else
        local v = FixedVector3.New(-FixedMath.HALF_PI
            , FixedMath.Atan2(-FixedNumber.TWO * (x * y - w * z), FixedNumber.ONE - FixedNumber.TWO * (y * y + z * z))
            , FixedNumber.ZERO)
        SanitizeEuler(v)
        v.x = FixedMath.Rad2Deg(v.x)
        v.y = FixedMath.Rad2Deg(v.y)
        v.z = FixedMath.Rad2Deg(v.z)
        return v
    end
end

FixedQuaternion.Forward = function(a)
    return a:MulVec3(FixedVector3.FORWARD)
end

FixedQuaternion.MulVec3 = function(a, point)
    local vec   = FixedVector3.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO)
    local num   = a.x * FixedNumber.TWO
    local num2  = a.y * FixedNumber.TWO
    local num3  = a.z * FixedNumber.TWO
    local num4  = a.x * num
    local num5  = a.y * num2
    local num6  = a.z * num3
    local num7  = a.x * num2
    local num8  = a.x * num3
    local num9  = a.y * num3
    local num10 = a.w * num
    local num11 = a.w * num2
    local num12 = a.w * num3
    vec.x = (((FixedNumber.ONE - (num5 + num6)) * point.x) + ((num7 - num12) * point.y)) + ((num8 + num11) * point.z)
    vec.y = (((num7 + num12) * point.x) + ((FixedNumber.ONE - (num4 + num6)) * point.y)) + ((num9 - num10) * point.z)
    vec.z = (((num8 - num11) * point.x) + ((num9 + num10) * point.y)) + ((FixedNumber.ONE - (num4 + num5)) * point.z)
    return vec
end

FixedQuaternion.Dot = function(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

FixedQuaternion.Angle = function(a, b)
    local dot = FixedQuaternion.Dot(a, b)
    if dot < FixedNumber.ZERO then
        dot = -dot
    end
    return FixedMath.Rad2Deg(FixedMath.Acos(FixedMath.Min(dot, FixedNumber.ONE)) * FixedNumber.TWO)
end

FixedQuaternion.AngleAxis = function(angle, axis)
    local normAxis = axis:Normalize()
    angle = FixedMath.Deg2Rad(angle) / FixedNumber.TWO
    local s = FixedMath.Sin(angle)
    local w = FixedMath.Cos(angle)
    local x = normAxis.x * s
    local y = normAxis.y * s
    local z = normAxis.z * s
    return FixedQuaternion.New(x, y, z, w)
end

FixedQuaternion.Euler = function(x, y, z)
    local t = FixedQuaternion.New(FixedNUmber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    return t:SetEuler(x, y, z)
end

FixedQuaternion.FromToRotation = function(from, to)
    local t = FixedQuaternion.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    return t:SetFromToRotation(from, to)
end

FixedQuaternion.Lerp = function(q1, q2, t)
    t = FixedMath.Clamp(t, FixedNumber.ZERO, FixedNumber.ONE)
    local q = FixedQuaternion.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    if FixedQuaternion.Dot(q1, q2) < FixedNumber.ZERO then
        q.x = q1.x + t * (-q2.x - q1.x)
        q.y = q1.y + t * (-q2.y - q1.y)
        q.z = q1.z + t * (-q2.z - q1.z)
        q.w = q1.w + t * (-q2.w - q1.w)
    else
        q.x = q1.x + (q2.x - q1.x) * t
        q.y = q1.y + (q2.y - q1.y) * t
        q.z = q1.z + (q2.z - q1.z) * t
        q.w = q1.w + (q2.w - q1.w) * t
    end
    q:SetNormalize()
    return q
end

FixedQuaternion.LookRotation = function(forward, up)
    local mag = forward:Magnitude()
    if mag <= FixedNumber.ZERO then
        error("error input forward "..tostring(forward))
        return nil
    end
    forward = forward / mag
    up = up or FixedVector3.UP
    local right = FixedVector3.Cross(up, forward)
    right:SetNormalize()
    up = FixedVector3.Cross(forward, right)
    right = FixedVector3.Cross(up, forward)
    local quat = FixedQuaternion.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)
    local rot = {
        {right.x, up.x, forward.x},
        {right.y, up.y, forward.y},
        {right.z, up.z, forward.z},
    };
    MatrixToQuaternion(rot, quat);
    return quat
end

local DOT95 = FixedNumber.FromRaw(FixedConsts.DOT95)

local function UnclampedSlerp(q1, q2, t)
    local dot = FixedQuaternion.Dot(q1, q2)
    if dot < FixedNumber.ZERO then
        dot = -dot
        q2 = -q2
    end
    if dot < DOT95 then
        local angle = FixedMath.Acos(dot)
        local invSinAngle = FixedNumber.ONE / FixedMath.Sin(angle)
        local t1 = FixedMath.Sin((FixedNumber.ONE - t) * angle) * invSinAngle
        local t2 = FixedMath.Sin(t * angle) * invSinAngle
        return FixedQuaternion.New(
            q1.x * t1 + q2.x * t2
            , q1.y * t1 + q2.y * t2
            , q1.z * t1 + q2.z * t2
            , q1.w * t1 + q2.w * t2)
    else
        q1 = FixedQuaternion.New(
            q1.x + t * (q2.x - q1.x)
            , q1.y + t * (q2.y - q1.y)
            , q1.z + t * (q2.z - q1.z)
            , q1.w + t * (q2.w - q1.w))
        q1:SetNormalize()
        return q1
    end
end

FixedQuaternion.Slerp = function(from, to, t)
    return UnclampedSlerp(from, to, FixedMath.Clamp(t, FixedNumber.ZERO, FixedNumber.ONE))
end

FixedQuaternion.RotateTowards = function(from, to, maxDegreesDelta)
    local angle = FixedQuaternion.Angle(from, to)
    if angle == FixedNumber.ZERO then
        return to
    end
    local t = FixedMath.Min(FixedNumber.ONE, maxDegreesDelta / angle)
    return UnclampedSlerp(from, to, t)
end

FixedQuaternion.INDENTITY = FixedQuaternion.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE)

FixedQuaternion.__index = FixedQuaternion

FixedQuaternion.__tostring = function(a)
    return "["..tostring(a.x)..","..tostring(a.y)..","..tostring(a.z)..","..tostring(a.w).."]"
end

FixedQuaternion.__mul = function(a, b)
    return FixedQuaternion.New(
        (((a.w * b.x) + (a.x * b.w)) + (a.y * b.z)) - (a.z * b.y)
        , (((a.w * b.y) + (a.y * b.w)) + (a.z * b.x)) - (a.x * b.z)
        , (((a.w * b.z) + (a.z * b.w)) + (a.x * b.y)) - (a.y * b.x)
        , (((a.w * b.w) - (a.x * b.x)) - (a.y * b.y)) - (a.z * b.z))
end

FixedQuaternion.__unm = function(a)
    return FixedQuaternion.New(-a.x, -a.y, -a.z, -a.w)
end

FixedQuaternion.__eq = function(a, b)
    return FixedQuaternion.Dot(a, b) >= FixedNumber.ONE
end

return FixedQuaternion