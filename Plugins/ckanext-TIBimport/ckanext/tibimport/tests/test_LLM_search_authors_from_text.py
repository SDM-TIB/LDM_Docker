#  pytest --ckan-ini=test.ini ckanext/tibimport/tests/test_LLM_search_authors_from_text.py -s -vv

from ckanext.tibimport.LLM_search_authors_from_text import LLMSearchAuthorsFromText
from ckanext.tibimport.tests.Mocks_LLM_search_authors_from_text import config_response, context_txt, authors_list_in_LUH, authors_list_in_LUH_responses, authors_dict_in_LUH
import time
from statistics import mean



def test_read_API_key_from_CKAN():
    obj = LLMSearchAuthorsFromText()

    assert obj.API_key

def test__config_request():
    obj = LLMSearchAuthorsFromText()

    config_dict = obj._config_request()
    # print(config_dict)
    assert config_dict == config_response

def test__read_prompt_context():
    obj = LLMSearchAuthorsFromText()

    prompt_context = obj._read_prompt_context()
    # print(prompt_context)

    assert prompt_context == context_txt

def test_search_for_author_in_text():
    obj = LLMSearchAuthorsFromText()

    # List to store all execution times
    execution_times = []
    total_start_time = time.time()

    # Start time for this iteration
    start_time = time.time()

    for author_str in authors_list_in_LUH:
        res = obj.search_for_author_in_text(author_str)
        # print("\n\n", res, "\n\n")
        assert res[0].get("firstName", False) or res[0].get("lastName", False)

        # Start time for this iteration
        # start_time = time.time()
        # res = obj.search_for_author_in_text(authors_list_in_LUH[x])

        # End time and calculate duration
    end_time = time.time()
    duration = end_time - start_time
        # Store the duration
        # execution_times.append(duration)

        # Print iteration number and its duration
        # print(f"Iteration {x + 1}: {duration:.4f} seconds")


        # assert res == authors_list_in_LUH_responses[x]

    # Calculate and print statistics
    total_time = time.time() - start_time
    # average_time = mean(execution_times)
    # max_time = max(execution_times)
    # min_time = min(execution_times)

    print("\nExecution Statistics:")
    print(f"Total time: {total_time:.4f} seconds")
    # print(f"Average time per iteration: {average_time:.4f} seconds")
    # print(f"Fastest iteration: {min_time:.4f} seconds")
    # print(f"Slowest iteration: {max_time:.4f} seconds")

