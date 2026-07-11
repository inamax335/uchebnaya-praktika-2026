# Кейс-задача № 4
# WEB-приложение "Каталог туров" (архитектура клиент-сервер, трёхзвенная)
# Стек: Python 3 + Flask (сервер приложений), MySQL (сервер БД),
# браузер (тонкий клиент). Развёртывание: любой WSGI-сервер (gunicorn/IIS+wfastcgi)

import os
from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Строка подключения к MySQL (логин/пароль/хост задаются переменной окружения)
app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get(
    "DATABASE_URI", "mysql+pymysql://tourism:tourism@localhost/tourism"
)
db = SQLAlchemy(app)


# --- Модели данных (соответствуют схеме БД "Туризм" из кейс-задачи № 3) ---

class Country(db.Model):
    __tablename__ = "countries"
    country_id = db.Column(db.Integer, primary_key=True)
    country_name = db.Column(db.String(100), nullable=False, unique=True)


class Tour(db.Model):
    __tablename__ = "tours"
    tour_id = db.Column(db.Integer, primary_key=True)
    tour_name = db.Column(db.String(150), nullable=False)
    country_id = db.Column(db.Integer, db.ForeignKey("countries.country_id"),
                           nullable=False)
    duration = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    country = db.relationship("Country")


class Order(db.Model):
    __tablename__ = "orders"
    order_id = db.Column(db.Integer, primary_key=True)
    client_name = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    tour_id = db.Column(db.Integer, db.ForeignKey("tours.tour_id"),
                        nullable=False)
    persons = db.Column(db.Integer, nullable=False, default=1)
    tour = db.relationship("Tour")


# --- Контроллеры (маршруты) ---

@app.route("/")
def index():
    """Главная страница: каталог туров."""
    tours = Tour.query.order_by(Tour.price).all()
    return render_template("index.html", tours=tours)


@app.route("/order/<int:tour_id>", methods=["GET", "POST"])
def order(tour_id):
    """Оформление заказа выбранного тура."""
    tour = Tour.query.get_or_404(tour_id)
    if request.method == "POST":
        new_order = Order(
            client_name=request.form["client_name"].strip(),
            phone=request.form["phone"].strip(),
            tour_id=tour.tour_id,
            persons=max(1, int(request.form.get("persons", 1))),
        )
        db.session.add(new_order)
        db.session.commit()
        return redirect(url_for("orders"))
    return render_template("order.html", tour=tour)


@app.route("/orders")
def orders():
    """Список оформленных заказов."""
    all_orders = Order.query.order_by(Order.order_id.desc()).all()
    return render_template("orders.html", orders=all_orders)


if __name__ == "__main__":
    app.run(debug=True)
