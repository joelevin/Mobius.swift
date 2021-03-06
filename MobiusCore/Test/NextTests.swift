// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import MobiusCore
import Nimble
import Quick

class NextTests: QuickSpec {
    private enum Effect {
        case send
        case refresh
    }

    private struct UnexpectedCase: Error {}

    // swiftlint:disable function_body_length
    override func spec() {
        describe("Next") {
            var sut: Next<String, Effect>!

            describe("init(model:effects:)") {
                context("when given a model and no effects") {
                    beforeEach {
                        sut = Next(model: "foo", effects: [])
                    }

                    it("should set the model property") {
                        expect(sut.model).to(equal("foo"))
                    }

                    it("should set the effects to an empty set") {
                        expect(sut.effects).to(beEmpty())
                    }
                }

                context("when given a set of effect and no model") {
                    beforeEach {
                        sut = Next(model: nil, effects: [.send, .refresh])
                    }

                    it("should set the model property to nil") {
                        expect(sut.model).to(beNil())
                    }

                    it("should set the effects to the given set") {
                        expect(sut.effects).to(contain([Effect.send, Effect.refresh]))
                    }
                }

                context("when given a model and effects") {
                    beforeEach {
                        sut = Next(model: "bar", effects: [.send])
                    }

                    it("should set the model property") {
                        expect(sut.model).to(equal("bar"))
                    }

                    it("should set the effects to the given set") {
                        expect(sut.effects).to(contain([Effect.send]))
                    }
                }

                context("when given no model and no effects") {
                    beforeEach {
                        sut = Next(model: nil, effects: [])
                    }

                    it("should set the model property to nil") {
                        expect(sut.model).to(beNil())
                    }

                    it("should set the effects to an empty set") {
                        expect(sut.effects).to(beEmpty())
                    }
                }
            }

            describe("creation methods") {
                describe("next(_:effects:)") {
                    it("should use an empty set as the default for effects") {
                        expect(Next<String, Effect>.next("foo").effects).to(beEmpty())
                    }

                    it("should set the model and effects properties") {
                        expect(Next<String, Effect>.next("foo", effects: [.refresh]).model).to(equal("foo"))
                        expect(Next<String, Effect>.next("foo", effects: [.refresh]).effects).to(contain(.refresh))
                    }
                }

                describe("set variant of dispatch(_:)") {
                    it("should set the model to nil") {
                        expect(Next<String, Effect>.dispatchEffects([.refresh]).model).to(beNil())
                    }

                    it("should set the model and effects properties") {
                        expect(Next<String, Effect>.dispatchEffects([.refresh]).effects).to(contain(.refresh))
                    }
                }

                describe("noChange") {
                    it("should not have a model") {
                        expect(Next<Int, NoEffect>.noChange.model).to(beNil())
                    }

                    it("should not have any effects") {
                        expect(Next<Int, Effect>.noChange.effects).to(beEmpty())
                    }
                }
            }

            describe("hasEffects") {
                context("when the Next has multiple effects") {
                    beforeEach {
                        sut = Next(model: nil, effects: [.send, .refresh])
                    }

                    it("should return true") {
                        expect(sut.hasEffects).to(beTrue())
                    }
                }

                context("when the Next has one effect") {
                    beforeEach {
                        sut = Next(model: nil, effects: [.refresh])
                    }

                    it("should return true") {
                        expect(sut.hasEffects).to(beTrue())
                    }
                }

                context("when the Next does not have any effects") {
                    it("should return false") {
                        expect(Next<String, Effect>(model: "foo", effects: []).hasEffects).to(beFalse())
                    }

                    it("should return false for a change with nil effects") {
                        expect(Next<String, Effect>(model: nil, effects: []).hasEffects).to(beFalse())
                    }

                    it("should return false for a noChange") {
                        expect(Next<String, Effect>.noChange.hasEffects).to(beFalse())
                    }
                }
            }

            #if swift(>=4.1)
            describe("Equatable") {
                context("when the model type is equatable") {
                    let model1 = "some text"
                    let model2 = "some other text"
                    let effect1 = "some event"
                    let effect2 = "different event from before"

                    it("should return true if model and effects are equal") {
                        let lhs = Next(model: model1, effects: [effect1])
                        let rhs = Next(model: model1, effects: [effect1])

                        expect(lhs == rhs).to(beTrue())
                    }

                    it("should return false if model are not equal but effects are") {
                        let lhs = Next(model: model1, effects: [effect1])
                        let rhs = Next(model: model2, effects: [effect1])

                        expect(lhs == rhs).to(beFalse())
                    }

                    it("should return false if model are equal but effects aren't") {
                        let lhs = Next(model: model1, effects: [effect1])
                        let rhs = Next(model: model1, effects: [effect2])

                        expect(lhs == rhs).to(beFalse())
                    }

                    it("should return false if neither model nor effects are equal") {
                        let lhs = Next(model: model1, effects: [effect1])
                        let rhs = Next(model: model2, effects: [effect2])

                        expect(lhs == rhs).to(beFalse())
                    }
                }
            }
            #endif

            describe("debug description") {
                context("when containing a model") {
                    it("should produce the appropriate description") {
                        let next = Next<Int, Int>(model: 3, effects: Set([1]))
                        let description = String(describing: next)
                        expect(description).to(equal("(3, [1])"))
                    }
                }

                context("when no model") {
                    it("should produce the appropriate description") {
                        let next = Next<Int, Int>(model: nil, effects: Set([1]))
                        let description = String(describing: next)
                        expect(description).to(equal("(nil, [1])"))
                    }
                }
            }
        }
    }

    // swiftlint:enable function_body_length
}
