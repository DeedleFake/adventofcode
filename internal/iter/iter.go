package iter

import (
	"cmp"
	"slices"
	"unsafe"
)

type Iter[T any] func(func(T) bool) bool

type Addable interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 | ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr | ~string
}

type Pair[T1, T2 any] struct {
	One T1
	Two T2
}

func Slice[E any, S ~[]E](s S) Iter[E] {
	return func(yield func(E) bool) bool {
		for _, v := range s {
			if !yield(v) {
				return false
			}
		}
		return false
	}
}

func RevSlice[E any, S ~[]E](s S) Iter[E] {
	return func(yield func(E) bool) bool {
		for i := len(s) - 1; i >= 0; i-- {
			if !yield(s[i]) {
				return false
			}
		}
		return false
	}
}

func Bytes(s string) Iter[byte] {
	return Slice(unsafe.Slice(unsafe.StringData(s), len(s)))
}

func RevBytes(s string) Iter[byte] {
	return RevSlice(unsafe.Slice(unsafe.StringData(s), len(s)))
}

func Runes(s string) Iter[rune] {
	return func(yield func(rune) bool) bool {
		for _, c := range s {
			if !yield(c) {
				return false
			}
		}
		return false
	}
}

func Windows[T any](i Iter[T], n int) Iter[[]T] {
	s := make([]T, 0, n)
	return func(yield func([]T) bool) bool {
		for v := range i {
			if len(s) < n {
				s = append(s, v)
				if len(s) == n {
					if !yield(s) {
						return false
					}
				}
				continue
			}
			shiftLeft(s, v)
			if !yield(s) {
				return false
			}
		}
		// TODO: Yield if the first window never even got filled?
		return false
	}
}

func Enum[T any](i Iter[T]) Iter[Pair[int, T]] {
	return func(yield func(Pair[int, T]) bool) bool {
		var n int
		return i(func(v T) bool {
			r := yield(Pair[int, T]{n, v})
			n++
			return r
		})
	}
}

func Map[From, To any](i Iter[From], m func(From) To) Iter[To] {
	return func(yield func(To) bool) bool {
		return i(func(v From) bool {
			return yield(m(v))
		})
	}
}

func Filter[T any](i Iter[T], where func(T) bool) Iter[T] {
	return func(yield func(T) bool) bool {
		return i(func(v T) bool {
			if where(v) {
				return yield(v)
			}
			return true
		})
	}
}

func TakeUntil[T any](i Iter[T], until func(T) bool) Iter[T] {
	return func(yield func(T) bool) bool {
		return i(func(v T) bool {
			if until(v) {
				return false
			}
			return yield(v)
		})
	}
}

func Position[T any](i Iter[T], where func(T) bool) int {
	return Count(TakeUntil(i, where))
}

func Any[T any](i Iter[T], check func(T) bool) bool {
	for v := range i {
		if check(v) {
			return true
		}
	}
	return false
}

func All[T any](i Iter[T], check func(T) bool) bool {
	return Any(i, func(v T) bool { return !check(v) })
}

func Sum[T Addable](i Iter[T]) (sum T) {
	return Reduce(i, sum, func(acc, cur T) T { return acc + cur })
}

func Count[T any](i Iter[T]) int {
	return Reduce(i, 0, func(acc int, cur T) int { return acc + 1 })
}

func Collect[T any](i Iter[T], dst []T) []T {
	return Reduce(i, dst, func(acc []T, cur T) []T { return append(acc, cur) })
}

func Reduce[T, R any](i Iter[T], initial R, reducer func(R, T) R) R {
	for v := range i {
		initial = reducer(initial, v)
	}
	return initial
}

func extent[T cmp.Ordered](i Iter[T], n int) (r []T) {
	compare := cmp.Compare[T]
	if n < 0 {
		compare = func(v1, v2 T) int { return cmp.Compare(v2, v1) }
		n = -n
	}

	for v := range i {
		i, _ := slices.BinarySearchFunc(r, v, compare)
		if len(r) < n {
			r = slices.Insert(r, i, v)
			continue
		}
		if i >= len(r) {
			continue
		}
		shiftRight(r[i:], v)
	}
	return r
}

func MinN[T cmp.Ordered](i Iter[T], n int) []T {
	return extent(i, n)
}

func MaxN[T cmp.Ordered](i Iter[T], n int) []T {
	return extent(i, -n)
}

func Min[T cmp.Ordered](i Iter[T]) (max T) {
	r := extent(i, 1)
	if len(r) == 0 {
		return max
	}
	return r[0]
}

func Max[T cmp.Ordered](i Iter[T]) (max T) {
	r := extent(i, -1)
	if len(r) == 0 {
		return max
	}
	return r[0]
}

func shiftLeft[E any, S ~[]E](s S, v E) {
	copy(s, s[1:])
	s[len(s)-1] = v
}

func shiftRight[E any, S ~[]E](s S, v E) {
	copy(s[1:], s)
	s[0] = v
}
