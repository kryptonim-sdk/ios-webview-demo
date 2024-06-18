extension Array {
  mutating func appendIfNotNil(_ element: Element?) {
    if let element = element {
      self.append(element)
    }
  }
}
