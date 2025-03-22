import plotly.express as px
import pandas as pd
import sqlite3
from dash import Dash, dcc, html
from dash.dependencies import Input, Output

conn = sqlite3.connect('chinook.db')
cursor = conn.cursor()

query_sales_by_date = '''
select InvoiceDate, sum(Total) as SalesAmount
from invoice
group by InvoiceDate
'''

query_sales_by_genre = '''
select g.Name as Genre, sum(il.UnitPrice * il.Quantity) as SalesAmount
from invoice_lines il
join tracks t ON il.TrackId = t.TrackId
join genres g ON t.GenreId = g.GenreId
group by g.Name
'''

df_sales_by_date = pd.read_sql(query_sales_by_date, conn)
df_sales_by_genre = pd.read_sql(query_sales_by_genre, conn)

df_sales_by_date.to_pickle('sales_by_date.pkl')
df_sales_by_genre.to_pickle('sales_by_genre.pkl')

app = Dash(__name__)

app.layout = html.Div([
    dcc.DatePickerRange(
        id='date-picker-range',
        start_date=df_sales_by_date['InvoiceDate'].min(),
        end_date=df_sales_by_date['InvoiceDate'].max(),
        display_format='YYYY-MM-DD'
    ),
    dcc.Graph(id='line-chart'),
    dcc.Graph(id='bar-chart')
])

@app.callback(
    [Output('line-chart', 'figure'),
     Output('bar-chart', 'figure')],
    [Input('date-picker-range', 'start_date'),
     Input('date-picker-range', 'end_date')]
)
def update_graph(start_date, end_date):
    df_filtered = df_sales_by_date[
        (df_sales_by_date['InvoiceDate'] >= start_date) & 
        (df_sales_by_date['InvoiceDate'] <= end_date)
    ]
    line_chart = px.line(df_filtered, x='InvoiceDate', y='SalesAmount', title='Sales by Invoice Date')
    
    bar_chart = px.bar(df_sales_by_genre, x='Genre', y='SalesAmount', title='Sales by Genre')

    return line_chart, bar_chart

if __name__ == '__main__':
    app.run_server(debug=True)
