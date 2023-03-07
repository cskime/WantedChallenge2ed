# Week 1-2

## GCD

- `DispatchWorkItem`을 사용하면 비동기 작업을 취소할 수 있음 (`cancel()`)
    ```swift
    let workItem = DispatchWorkItem { ... }

    // 실행
    DispatchQueue.global().async(execute: workItem)

    // 취소
    workItem.cancel()
    ```
- Work item의 `cancel()`은 **실제로 실행 중인 작업을 중지시키지는 않는다.**
- Work item의 `isCancelled` 속성을 변경시켜서, closure 안에서 이 flag로 작업을 실행하지 않게 처리해야 한다.
    ```swift
    let workItem = DispatchWorkItem {
        guard !self.workItem.isCancelled else {
            return
        }
        ...
    }
    ```

### DispatchQueue

- Serial Queue : 작업을 queue에 들어온 순서대로 실행한다.
    - Main dispatch queue는 serial queue
- Concurrent Queue : 작업이 들어오는 순서와 상관 없이 queue에 들어오는 작업을 바로바로 실행한다.
    - Global dispatch queue는 concurrent queue
- Custom Queue : Main과 global queue 외에 직접 dispatch queue를 만들 수 있다.
    - `DispatchQueue(label:)`로 만들면 기본 serial queue
    - `attributes`에 `.concurrent`를 지정하면 concurrent queue

### QoS(Quality of Service)

- 작업의 우선순위를 지정한다.
- 절대적인 순서가 지켜지지는 않지만, 전체적으로 높은 우선순위의 작업이 먼저 실행되는 경향을 보인다.
    - userInteractive와 background는 차이가 크므로 더 압도적으로 차이가 날 수는 있음
- 종류
    - User Interactive
    - User Initiated
    - Default
    - Utility
    - Background
    - Unspecified
- 정책에 따라 어떤 qos를 지정할 것인지 결정
    ```swift
    DispatchQueue.global(qos: .background).async(execute: workItem)
    DispatchQueue(label: "myQueue", qos: .userInteractive).async(execute: workItem)
    ```

## Operation

- GCD : 비동기 프로그래밍을 간결하게 만들어 주는 프레임워크
- 간결하다? == 단순해서 세부적으로 조작하기는 어렵다.
- `Operation`과 `OperationQueue`를 사용하면 좀 더 세부적으로 조작할 수 있다.
    - `Operation`은 직접 취소할 수 있다.
    - `Operation`은 작업 간 종속성을 설정할 수 있다. (어떤 작업이 끝난 뒤 실행되도록)
- GCD와 비교
    - `DispatchQueue` ~= `OperationQueue`
    - `DispatchQueue.main.async` ~= `OperationQueue.main.addOperation`
    - `DispatchWorkItem` ~= `BlockOperation`
    - `OperationQueue.main.async(execute:)` ~= `OperationQueue.main.addOperation(operation)`

### Operation

- An abstract class that represents the code and data associated with a single task.
    - `Operation`만 가지고는 특별한 기능을 하지 못하지만, 기본 구현 등을 가지고 있고 subclassing해서 기능을 override하여 사용하기 때문에 추상 클래스로 구현되었다.
    - `Operation`을 상속받는 custom operation을 구현하고, `main()` static method를 override하여 원하는 작업을 구현한다.
        ```swift
        class CustomOperation: Operation {
            override func main() {
                guard !isCancelled else { return }
                doSomething()
            }
        }
        ```
    - `BlockOperation`은 생성자로 전달하는 closure를 `main()` 안에서 실행한다고 생각해도 됨
- `Operation`은 global이 없다.
- `OperationQueue`는 serial queue가 따로 없고, concurrent 작업 수를 조정하여 serial queue처럼 동작하게 만들 수 있다.
    - `maxConcurrentOperationCount`를 1로 지정
    - GCD의 serial queue와 비슷하게 동작하지만, 완전히 똑같이 동작한다고 볼 수는 없다.

### GCD와 차이

- GCD에서는 `DispatchWorkItem`의 `cancel()` method를 실행해도 작업이 실제로 취소되지 않고 `isCancelled` 속성을 가지고 closure 안에서 다른 코드가 실행되지 못하게 막아야 한다.
- Operation은 `cancel()` method를 실행하면 특정 조건 하에 `OperationQueue`에 들어간 작업을 실제로 취소시킬 수 있다.
    - `OperationQueue`는 작업(`Operation`)이 실제로 종료되었다는 것을 인지하지 못하면, 실제로 취소했더라도 작업을 실행시킬 수 있다.
    - `OperationQueue`가 작업이 취소되었다는 것을 인지했다면, queue에 이미 들어가서 대기하고 있는 작업이 실행되지 못하게 취소시킬 수 있다.
    - 이 차이는 operation state에 의한 것
        - 문서에는 ready, executing, finish, cancel 네 가지 상태만 있지만, **pending** 상태도 존재한다.
        - Pending 상태에 있는 operation은 `cancel()`을 호출했을 때 곧 바로 취소되어 실행되지 않는다.

## GCD와 Operation 선택

- 간단한 작업은 GCD가 더 빠를 수도 있지만, GCD도 무거운 작업을 한 번에 많이 할당하면 성능이 오히려 떨어질 수 있다.
- 세부 조작을 잘 할 수 있으면 Operation을 사용하고, 그게 아니라 간단한 작업만 할 것이라면 GCD를 사용해도 좋다.
- 실제로 GCD는 Operation을 래핑한 프레임워크이므로, 구현상에 큰 차이는 없다. 시스템이 threading을 알아서 관리해 줘서 간단한 작업은 쉽고 빠르게 실행할 수 있는 것 뿐
- 결국, 상황과 용도에 맞게 선택해야 한다.
