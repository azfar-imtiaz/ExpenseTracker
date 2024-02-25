import os
import re
import csv
import json
import joblib
import coremltools
from typing import List
from unidecode import unidecode
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import CountVectorizer


category_mapping = {
    "Auto & Transport": 0,
    "Travel & Transport": 0,
    "Travel": 0,
    "Mobile Recharge": 1,
    "Bills & Utilities": 1,
    "Entertainment": 2,
    "Health & Beauty": 3,
    "Health & Wellness": 3,
    "Personal Care": 3,
    "Fees & Charges": 3,
    "Food & Dining": 4,
    "Home": 5,
    "Income": 6,
    "Shopping": 7,
    "Finance": 8,
    "Transfer": 8,
    "Business Services": 8,
    "Government": 8
}


def read_transactions(filename: str) -> List:
    rows = []
    with open(filename, 'r', encoding='ISO-8859-1') as rfile:
        for index, line in enumerate(rfile):
            if index == 0:
                continue
            try:
                transaction, category = line.split('\t')
            except ValueError:
                elements = line.split(" - ")
                if len(elements) > 2:
                    transaction = "".join(elements[:-1])
                    category = elements[-1]
                else:
                    transaction, category = line.split(' - ')
            if transaction.lower().find("västtrafik") >= 0 or transaction.lower().find("ryanair") >= 0 or transaction.lower().find("flygbussarna") >= 0:
                transaction_category = 0
            elif transaction.lower().find("g@teborgs stads") >= 0 or transaction.lower().find("skandia") >= 0:
                transaction_category = 1
            elif transaction.find("YAKI-DA") >= 0 or transaction.lower().find("universeum") >= 0:
                transaction_category = 2
            elif transaction.lower().find("Överföring via internet") >= 0 or transaction.lower().find("collectia") >= 0:
                transaction_category = 8
            elif transaction.lower().find("elgiganten") >= 0 or transaction.lower().find("stadium") >= 0 or transaction.lower().find("willys") >= 0:
                transaction_category = 7
            elif transaction.lower().find("lön") >= 0:
                transaction_category = 6
            else:
                transaction_category = category_mapping[category.strip()]

            transaction = re.sub(r'\d+', 'NUM', transaction)
            transaction = re.sub(r'(?<=\w)[^a-zA-Z\s\.\@](?=\w)', ' ', transaction)
            transaction = unidecode(transaction)
            rows.append({
                "transaction_title": transaction.strip(),
                "transaction_category": transaction_category
            })
    return rows


def classify_transactions(input_filename, output_filename, clf, vectorizer):
    transactions_to_classify = []
    with open(input_filename, 'r', encoding='ISO-8859-1') as rfile:
        reader = csv.reader(rfile)
        for index, row in enumerate(reader):
            if index < 2:
                continue
            transaction_title = row[9].strip()
            transaction_title = re.sub(r'\d+', 'NUM', transaction_title)
            transactions_to_classify.append(transaction_title)
    vectorized_transactions = vectorizer.transform(transactions_to_classify)
    predictions = clf.predict(vectorized_transactions)

    """
    for index in range(len(transactions_to_classify)):
        if predictions[index] == 4:
            print(f"{transactions_to_classify[index]} -> {predictions[index]}")
    """

    with open(output_filename, 'w') as wfile:
        writer = csv.writer(wfile)
        writer.writerow(["Transaction_Title", "Category"])
        for index in range(len(transactions_to_classify)):
            transaction = transactions_to_classify[index]
            if transaction.lower().find("västtrafik") >= 0 or transaction.lower().find("ryanair") >= 0 or transaction.lower().find("flygbussarna") >= 0:
                transaction_category = 0
            elif transaction.lower().find("g@teborgs stads") >= 0 or transaction.lower().find("skandia") >= 0:
                transaction_category = 1
            elif transaction.find("YAKI-DA") >= 0 or transaction.lower().find("universeum") >= 0:
                transaction_category = 2
            elif transaction.lower().find("Överföring via internet") >= 0 or transaction.lower().find("collectia") >= 0:
                transaction_category = 8
            elif transaction.lower().find("elgiganten") >= 0 or transaction.lower().find("stadium") >= 0 or transaction.lower().find("willys") >= 0:
                transaction_category = 7
            elif transaction.lower().find("lön") >= 0:
                transaction_category = 6
            else:
                transaction_category = predictions[index]
            writer.writerow([transaction, transaction_category])


# def classify_transactions(input_filename, output_filename, pipeline):
#     transactions_to_classify = []
#     with open(input_filename, 'r', encoding='ISO-8859-1') as rfile:
#         reader = csv.reader(rfile)
#         for index, row in enumerate(reader):
#             if index < 2:
#                 continue
#             transaction_title = row[9].strip()
#             transactions_to_classify.append(transaction_title)
#     predictions = pipeline.predict(transactions_to_classify)
#     for index in range(len(transactions_to_classify)):
#         if predictions[index] == 4:
#             print(f"{transactions_to_classify[index]} -> {predictions[index]}")

#     with open(output_filename, 'w') as wfile:
#         writer = csv.writer(wfile)
#         writer.writerow(["Transaction_Title", "Category"])
#         for index in range(len(transactions_to_classify)):
#             transaction = transactions_to_classify[index]
#             if transaction.lower().find("västtrafik") >= 0 or transaction.lower().find("ryanair") >= 0 or transaction.lower().find("flygbussarna") >= 0:
#                 transaction_category = 0
#             elif transaction.lower().find("g@teborgs stads") >= 0 or transaction.lower().find("skandia") >= 0:
#                 transaction_category = 1
#             elif transaction.find("YAKI-DA") >= 0 or transaction.lower().find("universeum") >= 0:
#                 transaction_category = 2
#             elif transaction.lower().find("Överföring via internet") >= 0 or transaction.lower().find("collectia") >= 0:
#                 transaction_category = 8
#             elif transaction.lower().find("elgiganten") >= 0 or transaction.lower().find("stadium") >= 0 or transaction.lower().find("willys") >= 0:
#                 transaction_category = 7
#             elif transaction.lower().find("lön") >= 0:
#                 transaction_category = 6
#             else:
#                 transaction_category = predictions[index]
#             writer.writerow([transaction, transaction_category])


def convert_model_to_coreml(model_filename: str):
    model = joblib.load(model_filename)
    coreml_model = coremltools.converters.sklearn.convert(model)

    coreml_model.save('transactionClassifier_coreml.mlmodel')


if __name__ == '__main__':
    model_name = "transactionClassifier_sklearn.pkl"
    vocabulary_filename = "vocabulary.json"
    transactions = read_transactions("training_data.txt")

    if not os.path.exists(model_name):
        transactions_train, transactions_test = train_test_split(transactions, test_size=0.2)
        pipeline = Pipeline([
            ('vectorizer', CountVectorizer(stop_words='english')),
            ('classifier', RandomForestClassifier(n_estimators=200))
        ])
        vectorizer = CountVectorizer(stop_words='english')
        print("Vectorizing documents...")
        vectorized_documents_train = vectorizer.fit_transform([t['transaction_title'] for t in transactions_train])

        clf = RandomForestClassifier(n_estimators=200)
        clf.fit(vectorized_documents_train, [t['transaction_category'] for t in transactions_train])

        vectorized_documents_test = vectorizer.transform([t['transaction_title'] for t in transactions_test])
        predictions = clf.predict(vectorized_documents_test)

        # pipeline.fit(
        #     [t['transaction_title'] for t in transactions_train],
        #     [t['transaction_category'] for t in transactions_train],
        # )

        # predictions = pipeline.predict([t['transaction_title'] for t in transactions_test])

        print(classification_report(
            y_true=[t['transaction_category'] for t in transactions_test],
            y_pred=predictions
        ))

        transactions_to_classify_filename = "transactions_23-24.csv"
        output_filename = "classified_transactions_23-24.csv"
        classify_transactions(
            input_filename=transactions_to_classify_filename,
            output_filename=output_filename,
            clf=clf,
            vectorizer=vectorizer
        )

        # classify_transactions(
        #     input_filename=transactions_to_classify_filename,
        #     output_filename=output_filename,
        #     pipeline=pipeline
        # )

        with open(vocabulary_filename, 'w', encoding='ISO-8859-1') as wfile:
            json.dump(vectorizer.vocabulary_, wfile)
        joblib.dump(clf, model_name)
    else:
        print("Classifier already exists on disk!")

    convert_model_to_coreml(model_filename=model_name)
