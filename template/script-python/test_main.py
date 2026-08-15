import unittest

from main import greeting


class GreetingTest(unittest.TestCase):
    def test_greeting(self) -> None:
        self.assertEqual(greeting(), "Hello, Python!")


if __name__ == "__main__":
    unittest.main()
