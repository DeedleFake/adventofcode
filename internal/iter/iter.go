package iter

type Iter[T any] func(func(T) bool) bool

type Addable interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 | ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr | ~string
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
