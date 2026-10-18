# Backend deployment notes

The working FastAPI backend currently runs in Google Colab and loads the IndicTrans2 model. Colab/ngrok is suitable for prototype tests only. Before production:
- deploy the API to a GPU-capable server with sufficient memory;
- keep model/provider tokens only in server-side environment variables/secrets;
- add authentication, rate limiting, request size limits, monitoring and HTTPS;
- validate `source_language`/`target_language` server-side;
- do not expose arbitrary stack traces to clients;
- pin reviewed model-code revisions and dependencies;
- do not assume free hosting can hold/load a 4+ GB model.

The Flutter package expects `POST /translate` with `{"text":"..."}` and a JSON response containing `"translated_text"`.
