import thunk from 'redux-thunk'
import { composeWithDevTools } from 'redux-devtools-extension'
import { applyMiddleware, createStore } from 'redux'
import reducer from '../reducer'
let _store

export function configureStore (initialState = {}, injectedThunk = {}) {
  _store = createStore(
    reducer,
    initialState,
    composeWithDevTools(applyMiddleware(thunk.withExtraArgument(injectedThunk)))
  )
  return _store
}

export const store = _store
