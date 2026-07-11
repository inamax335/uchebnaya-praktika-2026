# Кейс-задача № 2
# Тестовая программа, демонстрирующая работу методов
# базового и производного классов.


class Employee:
    """Базовый класс - Сотрудник."""

    def __init__(self, name: str, salary: float):
        self.name = name
        self.salary = salary

    def info(self) -> str:
        """Метод базового класса: информация о сотруднике."""
        return f"Сотрудник: {self.name}"

    def monthly_payment(self) -> float:
        """Метод базового класса: расчёт месячной выплаты."""
        return self.salary

    def __str__(self) -> str:
        return f"{self.info()}, выплата за месяц: {self.monthly_payment():.2f} руб."


class Programmer(Employee):
    """Производный класс - Программист. Наследует Employee."""

    def __init__(self, name: str, salary: float, language: str, bonus: float):
        super().__init__(name, salary)      # вызов конструктора базового класса
        self.language = language
        self.bonus = bonus

    def info(self) -> str:
        """Переопределение метода базового класса."""
        base = super().info()               # используем метод базового класса
        return f"{base} (программист, язык: {self.language})"

    def monthly_payment(self) -> float:
        """Переопределение: оклад + премия."""
        return super().monthly_payment() + self.bonus

    def write_code(self) -> str:
        """Собственный метод производного класса."""
        return f"{self.name} пишет код на {self.language}"


if __name__ == "__main__":
    print("=== Объект базового класса ===")
    emp = Employee("Петров П.П.", 60000)
    print(emp.info())
    print(emp)

    print("\n=== Объект производного класса ===")
    prog = Programmer("Смолькин В.А.", 80000, "Python", 15000)
    print(prog.info())            # переопределённый метод
    print(prog.write_code())      # собственный метод производного класса
    print(prog)

    print("\n=== Полиморфизм: единый интерфейс для разных классов ===")
    for person in (emp, prog):
        print(f"{person.name}: {person.monthly_payment():.2f} руб.")

    print("\n=== Проверка наследования ===")
    print("Programmer - подкласс Employee:", issubclass(Programmer, Employee))
    print("prog - экземпляр Employee:", isinstance(prog, Employee))
