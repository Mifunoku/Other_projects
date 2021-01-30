from flask import Flask, render_template, redirect, url_for, request
import os
from werkzeug.utils import secure_filename
import tempfile
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
import io
import base64

ROOT_DIR = os.path.abspath(os.path.dirname(__file__))

app = Flask(__name__)

def search_for_categories(df):
    numeric, categorical = [], []
    for col in df.columns:
        if pd.api.types.is_numeric_dtype(df[col]):
            numeric.append(col)
        else:
            categorical.append(col)
    return numeric, categorical


@app.route("/")
def main_page():
    return render_template("main_page.html")

@app.route("/authors")
def authors():
    return render_template("authors.html")

@app.route("/analysis", methods=["POST", "GET"])
def analysis():
    global df
    if request.method == "POST":
        numeric = None
        categorical = None
        try:
            file = request.files["file"]
        except:
            file = None
        try:
            selected_1 = request.form.get("numerical_1")
        except:
            selected_1 = None
        try:
            selected_2 = request.form.get("numerical_2")
        except:
            selected_2 = None
        try:
            selected_3 = request.form.get("categorical_3")
        except:
            selected_3 = None
        if file and not (selected_1 and selected_2 and selected_3):
            filename = secure_filename(file.filename)
            file_path = os.path.join(tempfile.gettempdir(), filename)
            file.save(file_path)
            if filename[-4:] == (".csv" or ".CSV"):
                df = pd.read_csv(file_path)
                numeric, categorical = search_for_categories(df)

            else:
                #tu trzeba będzie wrzucić jakiś komunikat o błędzie żeby podać poprawny plik tekstowy czy coś
                with open(file_path, 'r') as f:
                    categorical = f.read()
                    numeric = len(categorical)
            return render_template("analysis.html", categorical=categorical, numerical=numeric)
        elif selected_1 and selected_2 and selected_3:

            def average(choice_1, choice_2, choice_3):
                categories = df[choice_3].unique()
                category, mean_1, mean_2 = [], [], []
                for cat in categories:
                    category.append(cat)
                    c = df.loc[df[choice_3] == cat]
                    series_1 = pd.Series(c[choice_1])
                    mean_1.append(series_1.mean())
                    series_2 = pd.Series(c[choice_2])
                    mean_2.append(series_2.mean())
                return category, mean_1, mean_2

            def get_line_drawing(x, y,z):
                """Create plot and return Figure object"""
                category, mean_1, mean_2 = average(x, y, z)
                category_avg=[]
                for name in category:
                    name = "średnia " + name
                    category_avg.append(name)
                groups = df.groupby(z)
                fig, ax = plt.subplots()
                for name, group in groups:
                    ax.scatter(group[x], group[y], marker="o", label=name)
                for i in range(len(category_avg)):
                    ax.scatter(mean_1[i], mean_2[i], marker="o",s=200, label=category_avg[i], alpha=0.5)
                ax.grid(alpha=0.2)
                ax.legend(loc=2, bbox_to_anchor=(1, 1.01), fontsize='small', shadow=1)
                ax.set_xlabel(x)
                ax.set_ylabel(y)
                return fig

            def translate_image_to_base64(fig):
                """Get Figure object and return its base64 representation."""
                buffer = io.BytesIO()
                fig.savefig(buffer, format='png', bbox_inches='tight')
                buffer.seek(0)
                b_64 = base64.b64encode(buffer.getvalue()).decode()
                plt.close(fig)
                return f"data:image/png;base64,{b_64}"
            #create plot    
            fig = get_line_drawing(selected_1, selected_2, selected_3)
            draw = translate_image_to_base64(fig)
            #create table
            category, mean_1, mean_2 = average(selected_1, selected_2, selected_3)

        return render_template("analysis.html", selected_1=selected_1, selected_2=selected_2, selected_3=selected_3, drawing=draw, category=category, mean_1=mean_1, mean_2=mean_2)
    return render_template("analysis.html")


if __name__ == "__main__":
    app.run()
