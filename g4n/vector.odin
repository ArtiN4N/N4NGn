package g4n

import sdl "vendor:sdl3"

import "core:math"
import "core:log"

IVector :: sdl.Point
FVector :: sdl.FPoint
TVector :: [2]u32

IVECTOR_ZERO  :: IVector{0,0}
FVECTOR_ZERO :: FVector{0,0}
TVECTOR_ZERO :: TVector{0,0}


ivector_to_fvector :: proc(v: IVector) -> (r: FVector) {
    r.x = f32(v.x)
    r.y = f32(v.y)
    return
}
tvector_to_fvector :: proc(v: TVector) -> (r: FVector) {
    r.x = f32(v.x)
    r.y = f32(v.y)
    return
}
to_fvector :: proc{ivector_to_fvector, tvector_to_fvector}




ivector_to_tvector :: proc(v: IVector, loc := #caller_location) -> (r: TVector) {
    if v.x < 0 || v.y < 0 {
        log.logf(.Warning, "Casting negative int to uint from %v.", loc)
    }

    r.x = u32(v.x)
    r.y = u32(v.y)
    return
}
fvector_to_tvector :: proc(v: FVector, loc := #caller_location) -> (r: TVector) {
    if v.x < 0 || v.y < 0 {
        log.logf(.Warning, "Casting negative float to uint from %v.", loc)
    }
    r.x = u32(v.x)
    r.y = u32(v.y)
    return
}
to_tvector :: proc{ivector_to_tvector, fvector_to_tvector}




fvector_to_ivector :: proc(v: FVector) -> (r: IVector) {
    r.x = i32(v.x)
    r.y = i32(v.y)
    return
}
tvector_to_ivector :: proc(v: TVector) -> (r: IVector) {
    r.x = i32(v.x)
    r.y = i32(v.y)
    return
}
to_ivector :: proc{fvector_to_ivector, tvector_to_ivector}




floor_fvector :: proc(i: FVector) -> (r: FVector){
    r.x = math.floor(i.x)
    r.y = math.floor(i.y)

    return
}
ceil_fvector :: proc(i: FVector) -> (r: FVector){
    r.x = math.ceil(i.x)
    r.y = math.ceil(i.y)

    return
}




ivector_add :: proc(a, b: IVector) -> (r: IVector)  {
    r = a + b
    return
}
fvector_add :: proc(a, b: FVector) -> (r: FVector)  {
    r = a + b
    return
}
tvector_add :: proc(a, b: TVector) -> (r: TVector)  {
    r = a + b
    return
}
vector_add :: proc{ivector_add, fvector_add, tvector_add}




ivector_sub :: proc(a, b: IVector) -> (r: IVector)  {
    r = a - b
    return
}
fvector_sub :: proc(a, b: FVector) -> (r: FVector)  {
    r = a - b
    return
}
tvector_sub :: proc(a, b: TVector) -> (r: TVector)  {
    r = a - b
    return
}
vector_sub :: proc{ivector_sub, fvector_sub, tvector_sub}




ivector_abs :: proc(a: IVector) -> (r: IVector)  {
    r.x = abs(a.x)
    r.y = abs(a.y)
    return
}
fvector_abs :: proc(a: FVector) -> (r: FVector)  {
    r.x = abs(a.x)
    r.y = abs(a.y)
    return
}
tvector_abs :: proc(a: TVector) -> (r: TVector)  {
    r.x = abs(a.x)
    r.y = abs(a.y)
    return
}
vector_abs :: proc{ivector_abs, fvector_abs, tvector_abs}




ivector_mult_scalar :: proc(a: IVector, b: i32) -> (r: IVector) {
    r = a * b
    return
}
fvector_mult_scalar :: proc(a: FVector, b: f32) -> (r: FVector) {
    r = a * b
    return
}
tvector_mult_scalar :: proc(a: TVector, b: u32) -> (r: TVector) {
    r = a * b
    return
}
vector_mult_scalar :: proc{ivector_mult_scalar, fvector_mult_scalar, tvector_mult_scalar}




ivector_div_scalar :: proc(a: IVector, b: i32, loc := #caller_location) -> (r: IVector) {
    if b == 0 {
        log.logf(.Fatal, "Undefined behaviour: Division by 0!")
        panic("FATAL crash! See log file for info.")
    }
    r = a / b
    return
}
fvector_div_scalar :: proc(a: FVector, b: f32, loc := #caller_location) -> (r: FVector) {
    if b == 0 {
        log.logf(.Fatal, "Undefined behaviour from %v: Division by 0!", loc)
        panic("FATAL crash! See log file for info.")
    }
    r = a / b
    return
}
tvector_div_scalar :: proc(a: TVector, b: u32, loc := #caller_location) -> (r: TVector) {
    if b == 0 {
        log.logf(.Fatal, "Undefined behaviour from %v: Division by 0!", loc)
        panic("FATAL crash! See log file for info.")
    }
    r = a / b
    return
}
vector_div_scalar :: proc{ivector_div_scalar, fvector_div_scalar, tvector_div_scalar}




ivector_cross :: proc(a, b: IVector) -> (r: i32)  {
    r = a.x*b.y - b.x*a.y
    return
}
fvector_cross :: proc(a, b: FVector) -> (r: f32)  {
    r = a.x*b.y - b.x*a.y
    return
}
tvector_cross :: proc(a, b: TVector) -> (r: i32)  {
    r = ivector_cross(to_ivector(a), to_ivector(b))
    return
}
vector_cross :: proc{ivector_cross, fvector_cross, tvector_cross}




ivector_dist :: proc(a, b: IVector) -> (r: f32) {
    diff := to_fvector(a - b)
    r = math.sqrt(math.pow(diff.x, 2) + math.pow(diff.y, 2))
    return
}
fvector_dist :: proc(a, b: FVector) -> (r: f32) {
    diff := a - b
    r = math.sqrt(math.pow(diff.x, 2) + math.pow(diff.y, 2))
    return
}
tvector_dist :: proc(a, b: TVector) -> (r: f32) {
    diff := to_fvector(a) - to_fvector(b)
    r = math.sqrt(math.pow(diff.x, 2) + math.pow(diff.y, 2))
    return
}
vector_dist :: proc{ivector_dist, fvector_dist, tvector_dist}




ivector_magnitude :: proc(a: IVector) -> (r: f32) {
    r = vector_dist(a, IVECTOR_ZERO)
    return
}
fvector_magnitude :: proc(a: FVector) -> (r: f32) {
    r = vector_dist(a, FVECTOR_ZERO)
    return
}
tvector_magnitude :: proc(a: TVector) -> (r: f32) {
    r = vector_dist(a, TVECTOR_ZERO)
    return
}
vector_magnitude :: proc{ivector_magnitude, fvector_magnitude, tvector_magnitude}




ivector_normalize :: proc(a: IVector) -> (r: FVector) {
    a := to_fvector(a)
    r = vector_div_scalar(a, vector_magnitude(a))
    return
}
fvector_normalize :: proc(a: FVector) -> (r: FVector) {
    r = vector_div_scalar(a, vector_magnitude(a))
    return
}
tvector_normalize :: proc(a: TVector) -> (r: FVector) {
    a := to_fvector(a)
    r = vector_div_scalar(a, vector_magnitude(a))
    return
}
vector_normalize :: proc{ivector_normalize, fvector_normalize, tvector_normalize}