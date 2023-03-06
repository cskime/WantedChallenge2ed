# Week 1-1

## 동시성 프로그래밍(Concurrency Programming)이란?

- 동기(sync) 프로그래밍
    - 작업의 시작과 완료가 붙어있는 것
    - 이벤트의 종료와 시작이 종속적인 것
    - 작업의 시작이 이전 작업의 종료에 의존적인 것
- 비동기(async) 프로그래밍
    - 프로그램의 흐름과 이벤트 발생 및 처리를 독립적으로 수행
    - 앞에 작업과 상관 없이 알아서 실행된다.
- 비동기 != 동시성
    - 비동기(async) : 프로그램 흐름과 이벤트의 발생 및 처리를 독립적으로 수행하는 방법
    - 동시성(concurrency) : 여러 작업이 논리적인 관점에서 **동시에 수행되는 것 처럼** 보이게 하는 것
        - CPU가 엄청 빠르게 번갈아가면서 작업하는 것
        - 실제로는 동시에 하는게 아니지만, 우리한테는 동시에 하는 것 처럼 보임
        - CPU의 여러 개 코어가 각각 동시성 프로그래밍을 하고 있다.
    - 병렬(parallel) : 여러 작업이 물리적인 관점에서 동시에 수행되는 것
        - 여러 개 코어(core)로 하는 거
        - 세 코어가 같거나 유사한 작업을 할 때

## 애플 생태계 속의 동시성 프로그래밍 기술

- 사람이 일일이 작업들을 할당해 줄 수 없음
- 애플은 동시성 프로그래밍을 쉽게 구현할 수 있는 방법을 제공함
    - GCD, OperationQueue 같은 동시성 프로그래밍 기술 전에는 Thread를 직접 관리했었다.
    - Thread를 직접 관리할 때는 여러 개의 작업들을 여러 코어에 직접 할당해 줬어야 했다.
    - GCD, OperationQueue 같은 프레임워크는 동시성 프로그래밍 구현을 쉽게 해 준다.
        - _아마도, 어려운 일이었던 Thread를 코어에 할당하는 것을 대신 해 줄 것이다._
- `Dispatch` Framework에서 동시성 관련 기능등을 제공함

### GCD(Grand Central Dispatch)

- 복잡한 thread 관리는 `Dispatch` Framework에 위임
- 개발자는 main/background thread만 결정해서 실행시킬 작업만 신경쓰면 된다.
- `DispatchQueue`는 들어온 작업들을 알아서 여유가 있는 thread에 할당한다.

### 참고
    - [Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
    - [Grand Central Dispatch](https://developer.apple.com/documentation/dispatch)

## Image를 다운로드하는 코드

```swift
let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in 
    guard let data = data, let image = UIImage(data: data) else {
        
        // 1.
        DispatchQueue.main.async {
            self?.imageView.image = UIImage(systemName: "photo")
        }
        
        return
    }
    
    // 2.
    DispatchQueue.main.async {
        self?.imageView.image = image
    }
}
task,resume()
```

- `dataTask(with:completionHandler:)` method는 background thread에서 실행됨
- 작업이 완료된 후 `completionHandler` closure도 background thread에서 실행
- `imageView.image = image` 같은 UI 작업은 반드시 main thread에서 실행해야 하므로, `completionHandler` 안에서 실행하면 runtime error가 발생한다.
- `imageView.image`에 image를 할당하는 코드를 항상 main thread에서 실행하기 위해, GCD의 main queue에서 비동기적으로 실행시킨다. 
