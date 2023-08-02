package iter

import (
	"cmp"
	"slices"
)

type Iter[T any] func(func(T) bool) bool

type Addable interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 | ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr | ~string
}

func Slice[E any, S ~[]E](s S) Iter[E] {
	return func(yield func(E) bool) bool {
		for _, v := range s {
			if !yield(v) {
				break
			}
		}
		return false
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

func Sum[T Addable](i Iter[T]) (sum T) {
	return Reduce(i, sum, func(acc, cur T) T { return acc + cur })
}

func Count[T any](i Iter[T]) int {
	return Reduce(i, 0, func(acc int, cur T) int { return acc + 1 })
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
		if i < 0 {
			i = 0
		}
		r[i] = v
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
